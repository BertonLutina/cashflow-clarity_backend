const express = require('express');
const cors = require('cors');

const stripeWebhookRouter = require('./routes/webhooks/stripeWebhook');
const authRoutes = require('./routes/auth');
const transactionRoutes = require('./routes/transactions');
const cashflowAdjustmentRoutes = require('./routes/cashflowAdjustments');
const treasuryRulesRoutes = require('./routes/treasuryRules');
const treasurySettingsRoutes = require('./routes/treasurySettings');
const reviewedNotificationRoutes = require('./routes/reviewedNotifications');
const expenseCategoryRoutes = require('./routes/expenseCategories');
const cashflowEntryRoutes = require('./routes/cashflowEntries');
const subscriptionRoutes = require('./routes/subscription');
const subscriptionsRoutes = require('./routes/subscriptions');
const checkoutRoutes = require('./routes/checkout');
const checkoutSessionsRoutes = require('./routes/checkoutSessions');

const app = express();

app.use(cors({ origin: true, credentials: true }));

// Stripe webhook needs raw body for signature verification - must be before express.json
app.use('/api/webhooks/stripe', express.raw({ type: 'application/json' }), stripeWebhookRouter);

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

app.use('/api/auth', authRoutes);
app.use('/api/transactions', transactionRoutes);
app.use('/api/cashflow-adjustments', cashflowAdjustmentRoutes);
app.use('/api/treasury-rules', treasuryRulesRoutes);
app.use('/api/treasury-settings', treasurySettingsRoutes);
app.use('/api/reviewed-notifications', reviewedNotificationRoutes);
app.use('/api/expense-categories', expenseCategoryRoutes);
app.use('/api/cashflow-entries', cashflowEntryRoutes);
app.use('/api/subscription', subscriptionRoutes);
app.use('/api/subscriptions', subscriptionsRoutes);
app.use('/api/checkout', checkoutRoutes);
app.use('/api/checkout-sessions', checkoutSessionsRoutes);

app.get('/api/health', (req, res) => res.json({ status: 'ok' }));

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Internal server error' });
});

module.exports = app;
