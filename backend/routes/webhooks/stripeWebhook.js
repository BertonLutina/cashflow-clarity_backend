const express = require('express');
const router = express.Router();
const Stripe = require('stripe');
// NOTE: Raw body must be parsed at app level before express.json() - see app.js
const User = require('../../models/User');
const Subscription = require('../../models/Subscription');
const { broadcastCrud } = require('../../wsServer');

const stripe = process.env.STRIPE_SECRET_KEY
  ? new Stripe(process.env.STRIPE_SECRET_KEY)
  : null;
const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

/**
 * POST /api/webhooks/stripe
 * Stripe webhook - must use raw body for signature verification
 * Configure in Stripe Dashboard: checkout.session.completed, invoice.paid, customer.subscription.deleted
 */
router.post('/', async (req, res) => {
  if (!stripe || !webhookSecret) {
    console.error('Stripe webhook: STRIPE_SECRET_KEY or STRIPE_WEBHOOK_SECRET not set');
    return res.status(500).json({ error: 'Webhook not configured' });
  }

  const sig = req.headers['stripe-signature'];
  let event;

  try {
    event = stripe.webhooks.constructEvent(req.body, sig, webhookSecret);
  } catch (err) {
    console.error('Webhook signature verification failed:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  try {
    if (event.type === 'checkout.session.completed') {
      const session = event.data.object;
      const userEmail = session.metadata?.user_email || session.customer_email;
      const plan = session.metadata?.plan || 'standard';
      const subscriptionId = session.subscription;
      const userId = session.metadata?.user_id;

      if (!subscriptionId) {
        console.error('checkout.session.completed: no subscription id');
        return res.json({ received: true });
      }

      const stripeSub = await stripe.subscriptions.retrieve(subscriptionId);
      const periodEnd = new Date(stripeSub.current_period_end * 1000).toISOString();
      const gracePeriodEnd = new Date(stripeSub.current_period_end * 1000);
      gracePeriodEnd.setMonth(gracePeriodEnd.getMonth() + 1);

      let uid = userId ? parseInt(userId, 10) : null;
      if (!uid && userEmail) {
        const u = await User.findByEmail(userEmail);
        uid = u?.id;
      }
      if (!uid) {
        console.error('checkout.session.completed: could not resolve user_id for', userEmail);
        return res.json({ received: true });
      }

      await Subscription.upsertByUser(uid, {
        user_email: userEmail,
        plan,
        status: 'active',
        current_period_end: periodEnd,
        grace_period_end: gracePeriodEnd.toISOString(),
        external_id: subscriptionId,
      });
      broadcastCrud('subscription', 'update');
      console.log(`Subscription created/updated for ${userEmail}, plan: ${plan}`);
    }

    if (event.type === 'invoice.paid') {
      const invoice = event.data.object;
      const subscriptionId = invoice.subscription;
      if (!subscriptionId) return res.json({ received: true });

      const stripeSub = await stripe.subscriptions.retrieve(subscriptionId);
      const periodEnd = new Date(stripeSub.current_period_end * 1000).toISOString();
      const gracePeriodEnd = new Date(stripeSub.current_period_end * 1000);
      gracePeriodEnd.setMonth(gracePeriodEnd.getMonth() + 1);

      await Subscription.updateByExternalId(subscriptionId, {
        status: 'active',
        current_period_end: periodEnd,
        grace_period_end: gracePeriodEnd.toISOString(),
      });
      broadcastCrud('subscription', 'update');
      console.log(`Subscription renewed for ${subscriptionId}`);
    }

    if (event.type === 'customer.subscription.deleted') {
      const stripeSub = event.data.object;
      const subscriptionId = stripeSub.id;

      await Subscription.updateByExternalId(subscriptionId, {
        status: 'cancelled',
      });
      broadcastCrud('subscription', 'update');
      console.log(`Subscription cancelled for ${subscriptionId}`);
    }

    if (event.type === 'customer.subscription.updated') {
      const stripeSub = event.data.object;
      const subscriptionId = stripeSub.id;
      const periodEnd = new Date(stripeSub.current_period_end * 1000).toISOString();
      const gracePeriodEnd = new Date(stripeSub.current_period_end * 1000);
      gracePeriodEnd.setMonth(gracePeriodEnd.getMonth() + 1);

      await Subscription.updateByExternalId(subscriptionId, {
        status: stripeSub.status === 'active' ? 'active' : stripeSub.status,
        current_period_end: periodEnd,
        grace_period_end: gracePeriodEnd.toISOString(),
      });
      broadcastCrud('subscription', 'update');
    }
  } catch (err) {
    console.error('Webhook processing error:', err);
    return res.status(500).json({ error: 'Webhook handler failed' });
  }

  res.json({ received: true });
});

module.exports = router;
