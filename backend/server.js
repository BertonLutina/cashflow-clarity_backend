require('dotenv').config();
const app = require('./app');

const PORT = parseInt(process.env.PORT || '4000');

app.listen(PORT, () => {
  console.log(`Cashflow Clarity API running on http://localhost:${PORT}`);
});
