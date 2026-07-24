import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import OpenAI from "openai";
import { defineSecret } from "firebase-functions/params";

admin.initializeApp();
const db = admin.firestore();

// Define the secret parameter (will be fetched from Secret Manager)
const openAiApiKey = defineSecret("OPENAI_API_KEY");

const MAX_TOKENS_PER_DAY = 100000;
const FREE_CREDITS = 50;

export const chatWithAI = functions
  .runWith({ secrets: [openAiApiKey], timeoutSeconds: 300 })
  .https.onCall(async (data, context) => {
    // 1. Authenticate user
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "You must be logged in to use the AI."
      );
    }
    const uid = context.auth.uid;
    const { messages, model = "gpt-4o-mini", maxTokens = 1000 } = data;

    if (!messages || !Array.isArray(messages)) {
      throw new functions.https.HttpsError("invalid-argument", "Messages array is required.");
    }

    try {
      // 2. Check User Quota / Subscription
      const userRef = db.collection("users").doc(uid);
      const userDoc = await userRef.get();
      const userData = userDoc.data();
      
      let aiCredits = userData?.aiCredits ?? FREE_CREDITS;
      const isPremium = userData?.subscriptionTier === "pro" || userData?.subscriptionTier === "premium";

      if (!isPremium && aiCredits <= 0) {
        throw new functions.https.HttpsError(
          "resource-exhausted",
          "You have run out of AI credits. Please upgrade your plan."
        );
      }

      // 3. Initialize OpenAI
      const openai = new OpenAI({
        apiKey: openAiApiKey.value(),
      });

      // 4. Call OpenAI
      const completion = await openai.chat.completions.create({
        model: model,
        messages: messages,
        max_tokens: maxTokens,
      });

      const responseMessage = completion.choices[0]?.message?.content || "";
      const usage = completion.usage;
      const tokensUsed = usage?.total_tokens || 0;

      // Calculate approximate cost (e.g. $0.0002 / 1k tokens for 4o-mini)
      const cost = (tokensUsed / 1000) * 0.0002;

      // 5. Save logs and update usage
      const batch = db.batch();
      
      // Log usage globally
      const logRef = db.collection("ai_logs").doc();
      batch.set(logRef, {
        uid,
        model,
        tokensUsed,
        promptTokens: usage?.prompt_tokens || 0,
        completionTokens: usage?.completion_tokens || 0,
        cost,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Log conversation to user history
      const convoRef = userRef.collection("conversations").doc();
      batch.set(convoRef, {
        messages: [
          ...messages,
          { role: "assistant", content: responseMessage }
        ],
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Deduct credits if free user
      if (!isPremium) {
        batch.update(userRef, {
          aiCredits: admin.firestore.FieldValue.increment(-1), // simple request-based credit deduction
        });
      }

      await batch.commit();

      // 6. Return sanitized response
      return {
        success: true,
        response: responseMessage,
        tokensUsed,
        remainingCredits: isPremium ? 'unlimited' : aiCredits - 1
      };

    } catch (error: any) {
      console.error("AI Chat Error:", error);
      
      // Log error to Firestore
      await db.collection("ai_errors").add({
        uid,
        error: error.message,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }
      throw new functions.https.HttpsError("internal", "An error occurred while generating the response.");
    }
  });
