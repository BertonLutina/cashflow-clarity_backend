const Stripe = require('stripe');
const User = require('../models/User');
const CheckoutSession = require('../models/CheckoutSession');

const stripe = process.env.STRIPE_SECRET_KEY
  ? new Stripe(process.env.STRIPE_SECRET_KEY)
  : null;

const PRICE_IDS = {
  standard: process.env.STRIPE_PRICE_3MONTHS || process.env.STRIPE_PRICE_STANDARD || process.env.STRIPE_PRICE_ID,
  pro: process.env.STRIPE_PRICE_6MONTHS || process.env.STRIPE_PRICE_PRO,
  advanced: process.env.STRIPE_PRICE_12MONTHS || process.env.STRIPE_PRICE_ADVANCED,
};

/**
 * POST /api/checkout - Create Stripe Checkout Session
 * Redirects user to Stripe-hosted checkout for subscription
 */
exports.createSession = async (req, res) => {
  if (!stripe) {
    return res.status(501).json({
      error: 'Checkout not configured',
      message: 'Set STRIPE_SECRET_KEY and Stripe Price IDs in environment variables.',
    });
  }

  try {
    const { plan, success_url, cancel_url } = req.body;
    const planId = plan || 'standard';

    const priceId = PRICE_IDS[planId] || PRICE_IDS.standard;
    if (!priceId) {
      return res.status(400).json({
        error: 'Invalid plan',
        message: `No Stripe price configured for plan: ${planId}. Set STRIPE_PRICE_3MONTHS (standard), STRIPE_PRICE_6MONTHS (pro), or STRIPE_PRICE_12MONTHS (advanced) in backend/.env`,
      });
    }

    const user = await User.findById(req.userId);
    if (!user) return res.status(401).json({ error: 'User not found' });

    // Find or create Stripe customer
    const existingCustomers = await stripe.customers.list({
      email: user.email,
      limit: 1,
    });
    let customerId;
    if (existingCustomers.data.length > 0) {
      customerId = existingCustomers.data[0].id;
    } else {
      const customer = await stripe.customers.create({
        email: user.email,
        name: user.full_name || undefined,
      });
      customerId = customer.id;
    }

    const session = await stripe.checkout.sessions.create({
      customer: customerId,
      mode: 'subscription',
      line_items: [{ price: priceId, quantity: 1 }],
      success_url: success_url || `${process.env.APP_URL || 'http://localhost:5173'}/CashflowDashboard`,
      cancel_url: cancel_url || `${process.env.APP_URL || 'http://localhost:5173'}/Subscribe`,
      metadata: {
        user_id: String(req.userId),
        user_email: user.email,
        plan: planId,
      },
      subscription_data: {
        metadata: {
          user_id: String(req.userId),
          user_email: user.email,
          plan: planId,
        },
      },
    });

    await CheckoutSession.create(req.userId, {
      plan: planId,
      success_url: success_url || null,
      cancel_url: cancel_url || null,
      external_id: session.id,
      status: 'pending',
    });

    res.json({ url: session.url, session_id: session.id });
  } catch (err) {
    console.error('Checkout error:', err);
    res.status(500).json({
      error: 'Checkout failed',
      message: err.message || 'Failed to create checkout session',
    });
  }
};
