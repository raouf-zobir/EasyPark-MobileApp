const express = require("express");
const axios = require("axios");
const router = express.Router();


// routes/payment.js

const BASE_URL = process.env.PAYMENT_BASE_URL;
const APP_KEY = process.env.PAYMENT_APP_KEY;
const APP_SECRET = process.env.PAYMENT_APP_SECRET;
const NODE_ENV = process.env.NODE_ENV || "development";

// ‼️ IMPORTANT: This is your real test order number that can be queried.
const DEV_MODE_TEST_ORDER_NUMBER = "5D405O8YPM"; 

// Shared headers
const HEADERS = {
  Accept: "application/json",
  "Content-Type": "application/json",
  "x-app-key": APP_KEY,
  "x-app-secret": APP_SECRET,
};

// 🔹 Initiate Payment
router.post("/initiate", async (req, res) => {
  try {
    const { amount } = req.body;

    const response = await axios.post(
      `${BASE_URL}/initiate`,
      { amount: String(amount) },
      { headers: HEADERS }
    );
    
    // This part will run when your account is active (production mode)
    return res.json(response.data);

  } catch (error) {
    console.error("Error initiating payment (falling back to dev mode mock):", error.response?.data || error.message);

    // ‼️ THIS IS THE MODIFIED DEVELOPMENT MODE FALLBACK
    if (NODE_ENV === "development") {
      // We are simulating an immediate success to bypass the WebView
      // and test the rest of the app flow.
      return res.json({
        data: {
          type: "transaction_mock",
          id: DEV_MODE_TEST_ORDER_NUMBER, // We return a REAL, queryable test order ID
          attributes: {
            amount: String(req.body.amount),
            status: "mock_success",
            form_url: null, // No form URL is needed
          },
        },
        // We add a special meta flag to tell the Flutter app to skip the WebView
        meta: {
            mock_success: true,
            message: "Development mode: Skipped real payment and returned a testable order ID."
        }
      });
    }

    // This will run if an error happens in production
    res.status(error.response?.status || 500).json(error.response?.data || { error: error.message });
  }
});

// ... The rest of your payment.js file (show, receipt, email) remains unchanged ...
// They will work perfectly with the DEV_MODE_TEST_ORDER_NUMBER.

// 🔹 Show Payment Details
router.get("/show/:orderNumber", async (req, res) => {
  try {
    const { orderNumber } = req.params;

    const response = await axios.get(`${BASE_URL}/show`, {
      params: { order_number: orderNumber },
      headers: HEADERS,
    });

    res.json(response.data);
  } catch (error) {
    console.error("Error fetching payment details:", error.response?.data || error.message);

    if (NODE_ENV === "development") {
      return res.json({
        data: {
          type: "transaction",
          id: req.params.orderNumber,
          attributes: {
            amount: "300",
            order_number: req.params.orderNumber,
            status: "processing",
            form_url: "https://test.satim.dz/payment/mock_payment.html",
            confirmation_status: "requires_verification",
          },
        },
      });
    }

    res.status(error.response?.status || 500).json(error.response?.data || { error: error.message });
  }
});

// 🔹 Download Receipt
router.get("/receipt/:orderNumber", async (req, res) => {
  try {
    const { orderNumber } = req.params;

    const response = await axios.get(`${BASE_URL}/receipt`, {
      params: { order_number: orderNumber },
      headers: HEADERS,
    });

    res.json(response.data);
  } catch (error) {
    console.error("Error fetching receipt:", error.response?.data || error.message);

    if (NODE_ENV === "development") {
      return res.json({
        data: {
          type: "receipt",
          id: req.params.orderNumber,
          attributes: { receipt_url: "https://test.satim.dz/payment/mock_receipt.pdf" },
        },
      });
    }

    res.status(error.response?.status || 500).json(error.response?.data || { error: error.message });
  }
});

// 🔹 Email Receipt
router.post("/email", async (req, res) => {
  try {
    const { order_number, email } = req.body;

    const response = await axios.post(
      `${BASE_URL}/email`,
      { order_number, email },
      { headers: HEADERS }
    );

    res.json(response.data);
  } catch (error) {
    console.error("Error sending email receipt:", error.response?.data || error.message);

    if (NODE_ENV === "development") {
      return res.json({
        data: { message: `Email sent to ${email} (mock) for order ${order_number}` },
      });
    }

    res.status(error.response?.status || 500).json(error.response?.data || { error: error.message });
  }
});

module.exports = router;