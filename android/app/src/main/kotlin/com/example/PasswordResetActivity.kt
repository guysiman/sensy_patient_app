package com.example.sensy_patient_app

import android.os.Bundle
import android.view.View
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import com.google.firebase.auth.FirebaseAuth

class PasswordResetActivity : AppCompatActivity() {
    private lateinit var emailEditText: EditText
    private lateinit var otpEditText: EditText
    private lateinit var newPasswordEditText: EditText
    private lateinit var confirmPasswordEditText: EditText
    private lateinit var sendOtpButton: Button
    private lateinit var resetPasswordButton: Button
    private lateinit var auth: FirebaseAuth

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_password_reset)

        auth = FirebaseAuth.getInstance()

        emailEditText = findViewById(R.id.emailEditText)
        otpEditText = findViewById(R.id.otpEditText)
        newPasswordEditText = findViewById(R.id.newPasswordEditText)
        confirmPasswordEditText = findViewById(R.id.confirmPasswordEditText)
        sendOtpButton = findViewById(R.id.sendOtpButton)
        resetPasswordButton = findViewById(R.id.resetPasswordButton)

        sendOtpButton.setOnClickListener {
            sendPasswordResetEmail()
        }

        resetPasswordButton.setOnClickListener {
            resetPassword()
        }
    }

    private fun sendPasswordResetEmail() {
        val email = emailEditText.text.toString().trim()
        if (email.isEmpty()) {
            Toast.makeText(this, "Please enter your email", Toast.LENGTH_SHORT).show()
            return
        }

        auth.sendPasswordResetEmail(email)
            .addOnSuccessListener {
                Toast.makeText(this, "OTP sent to email. Check inbox.", Toast.LENGTH_LONG).show()
                otpEditText.visibility = View.VISIBLE
                newPasswordEditText.visibility = View.VISIBLE
                confirmPasswordEditText.visibility = View.VISIBLE
                resetPasswordButton.visibility = View.VISIBLE
            }
            .addOnFailureListener {
                Toast.makeText(this, "Error: ${it.message}", Toast.LENGTH_LONG).show()
            }
    }

    private fun resetPassword() {
        val newPassword = newPasswordEditText.text.toString().trim()
        val confirmPassword = confirmPasswordEditText.text.toString().trim()

        if (newPassword.length < 8 || !newPassword.matches(Regex(".*[A-Z].*")) ||
            !newPassword.matches(Regex(".*[0-9].*")) ||
            !newPassword.matches(Regex(".*[!@#\$%^&*].*"))) {
            Toast.makeText(this, "Weak password! Must be at least 8 characters with an uppercase letter, a number, and a special character.", Toast.LENGTH_LONG).show()
            return
        }

        if (newPassword != confirmPassword) {
            Toast.makeText(this, "Passwords do not match!", Toast.LENGTH_LONG).show()
            return
        }

        Toast.makeText(this, "Password reset successful! Please log in with your new password.", Toast.LENGTH_LONG).show()
        finish()
    }
}
