const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: process.env.SMTP_PORT,
  secure: false,
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

const sendOTPEmail = async (to, otp) => {
  await transporter.sendMail({
    from: `"StockSense" <${process.env.SMTP_USER}>`,
    to,
    subject: 'StockSense - Password Reset OTP',
    html: `<p>Your OTP for password reset is:</p><h2>${otp}</h2><p>This OTP is valid for 10 minutes.</p>`,
  });
};

module.exports = { sendOTPEmail };
