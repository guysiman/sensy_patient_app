package com.example.sensy_patient_app

import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseUser

class EmailPasswordActivity : AppCompatActivity() {

    private lateinit var auth: FirebaseAuth

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        auth = FirebaseAuth.getInstance() // Initialize Firebase Auth
    }

    override fun onStart() {
        super.onStart()
        // Check if user is signed in and update UI
        val currentUser = auth.currentUser
        updateUI(currentUser)
    }

    private fun updateUI(user: FirebaseUser?) {
        if (user != null) {
            Log.d("EmailPasswordActivity", "User signed in: ${user.email}")
        } else {
            Log.d("EmailPasswordActivity", "No user signed in")
        }
    }

    fun signUp(email: String, password: String) {
        auth.createUserWithEmailAndPassword(email, password)
            .addOnCompleteListener(this) { task ->
                if (task.isSuccessful) {
                    Log.d("EmailPasswordActivity", "createUserWithEmail:success")
                    val user = auth.currentUser
                    updateUI(user)
                } else {
                    Log.w("EmailPasswordActivity", "createUserWithEmail:failure", task.exception)
                    Toast.makeText(
                        baseContext, "Authentication failed.", Toast.LENGTH_SHORT
                    ).show()
                    updateUI(null)
                }
            }
    }

    fun signIn(email: String, password: String) {
        auth.signInWithEmailAndPassword(email, password)
            .addOnCompleteListener(this) { task ->
                if (task.isSuccessful) {
                    Log.d("EmailPasswordActivity", "signInWithEmail:success")
                    val user = auth.currentUser
                    updateUI(user)
                } else {
                    Log.w("EmailPasswordActivity", "signInWithEmail:failure", task.exception)
                    Toast.makeText(
                        baseContext, "Authentication failed.", Toast.LENGTH_SHORT
                    ).show()
                    updateUI(null)
                }
            }
    }

    fun resetPassword(email: String) {
        auth.sendPasswordResetEmail(email)
            .addOnCompleteListener { task ->
                if (task.isSuccessful) {
                    Log.d("EmailPasswordActivity", "Password reset email sent.")
                    Toast.makeText(baseContext, "Password reset email sent.", Toast.LENGTH_SHORT).show()
                } else {
                    Log.w("EmailPasswordActivity", "sendPasswordResetEmail:failure", task.exception)
                    Toast.makeText(baseContext, "Failed to send reset email.", Toast.LENGTH_SHORT).show()
                }
            }
    }
}
