//
//  PaymentService.swift
//  TLMS-project-main
//
//  Service for handling Razorpay payments
//

import Foundation
import Supabase
import Combine

@MainActor
class PaymentService: ObservableObject {
    private let supabase: SupabaseClient
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        self.supabase = SupabaseManager.shared.client
    }
    
    // MARK: - Create Payment Order
    
    func createPaymentOrder(courseId: UUID, userId: UUID, amount: Double) async -> PaymentOrder? {
        guard RazorpayConfig.isConfigured else {
            errorMessage = "Razorpay is not configured. Please add your API keys."
            return nil
        }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // Create order ID (in production, this should be done server-side)
            let orderId = "order_\(UUID().uuidString.prefix(14))"
            
            // Store payment record in database
            let payment = Payment(
                userId: userId,
                courseId: courseId,
                razorpayOrderId: orderId,
                amount: amount,
                currency: RazorpayConfig.currency,
                status: .pending
            )
            
            try await supabase
                .from("payments")
                .insert(payment)
                .execute()
            
            return PaymentOrder(
                orderId: orderId,
                amount: amount,
                currency: RazorpayConfig.currency
            )
        } catch {
            errorMessage = "Failed to create payment order: \(error.localizedDescription)"
            return nil
        }
    }
    
    // MARK: - Update Payment Status
    
    func updatePaymentStatus(orderId: String, paymentId: String?, status: PaymentStatus) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            struct PaymentUpdate: Encodable {
                let razorpay_payment_id: String?
                let status: String
            }
            
            let update = PaymentUpdate(
                razorpay_payment_id: paymentId,
                status: status.rawValue
            )
            
            try await supabase
                .from("payments")
                .update(update)
                .eq("razorpay_order_id", value: orderId)
                .execute()
            
            return true
        } catch {
            errorMessage = "Failed to update payment: \(error.localizedDescription)"
            return false
        }
    }
    
    
    // MARK: - Verify Payment
    
    func verifyPayment(orderId: String, paymentId: String, courseId: UUID, userId: UUID) async -> Bool {
        // For test mode: enroll user first, then update payment record
        // This ensures enrollment succeeds even if payment record update fails
        
        print("🔍 Verifying payment: orderId=\(orderId), paymentId=\(paymentId)")
        print("📚 Enrolling user \(userId) in course \(courseId)")
        
        // Enroll user in course FIRST (most important step)
        let courseService = CourseService()
        let enrolled = await courseService.enrollInCourse(courseID: courseId, userID: userId)
        
        if !enrolled {
            print("❌ Enrollment failed: \(courseService.errorMessage ?? "Unknown error")")
            errorMessage = courseService.errorMessage ?? "Failed to enroll in course"
            
            // Still try to update payment status to failed
            _ = await updatePaymentStatus(orderId: orderId, paymentId: paymentId, status: .failed)
            return false
        }
        
        print("✅ User enrolled successfully!")
        
        // Now update payment status (secondary step)
        let paymentUpdated = await updatePaymentStatus(
            orderId: orderId,
            paymentId: paymentId,
            status: .success
        )
        
        if paymentUpdated {
            print("✅ Payment record updated")
        } else {
            print("⚠️ Payment record update failed, but user is enrolled")
        }
        
        // Return true as long as enrollment succeeded
        return true
    }
    
    // MARK: - Get Payment URL
    
    func getPaymentURL(order: PaymentOrder, userEmail: String, userName: String) -> URL? {
        // Create a simple test payment form
        // Note: In production, you would use Razorpay's server-side API
        // For testing, we'll create a mock payment form
        
        let checkoutHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <meta charset="UTF-8">
            <style>
                * {
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                }
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    min-height: 100vh;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    padding: 20px;
                }
                .card {
                    background: white;
                    border-radius: 20px;
                    padding: 30px;
                    box-shadow: 0 20px 60px rgba(0,0,0,0.3);
                    max-width: 400px;
                    width: 100%;
                }
                .logo {
                    text-align: center;
                    margin-bottom: 20px;
                }
                .logo-icon {
                    width: 60px;
                    height: 60px;
                    background: #0056D2;
                    border-radius: 50%;
                    display: inline-flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 30px;
                    color: white;
                }
                h2 {
                    text-align: center;
                    color: #333;
                    margin-bottom: 10px;
                    font-size: 24px;
                }
                .amount {
                    text-align: center;
                    font-size: 36px;
                    font-weight: bold;
                    color: #0056D2;
                    margin: 20px 0;
                }
                .details {
                    background: #f8f9fa;
                    padding: 15px;
                    border-radius: 10px;
                    margin: 20px 0;
                }
                .detail-row {
                    display: flex;
                    justify-content: space-between;
                    margin: 8px 0;
                    font-size: 14px;
                }
                .detail-label {
                    color: #666;
                }
                .detail-value {
                    color: #333;
                    font-weight: 500;
                }
                .form-group {
                    margin: 15px 0;
                }
                label {
                    display: block;
                    margin-bottom: 5px;
                    color: #666;
                    font-size: 14px;
                }
                input {
                    width: 100%;
                    padding: 12px;
                    border: 2px solid #e0e0e0;
                    border-radius: 8px;
                    font-size: 16px;
                    transition: border-color 0.3s;
                }
                input:focus {
                    outline: none;
                    border-color: #0056D2;
                }
                .card-row {
                    display: flex;
                    gap: 10px;
                }
                .card-row input {
                    flex: 1;
                }
                button {
                    width: 100%;
                    background: #0056D2;
                    color: white;
                    border: none;
                    padding: 15px;
                    font-size: 18px;
                    font-weight: 600;
                    border-radius: 10px;
                    cursor: pointer;
                    margin-top: 20px;
                    transition: background 0.3s;
                }
                button:active {
                    background: #003d99;
                }
                .test-info {
                    background: #fff3cd;
                    border: 1px solid #ffc107;
                    padding: 10px;
                    border-radius: 8px;
                    margin-top: 15px;
                    font-size: 12px;
                    color: #856404;
                }
                .secured {
                    text-align: center;
                    margin-top: 20px;
                    color: #999;
                    font-size: 12px;
                }
            </style>
        </head>
        <body>
            <div class="card">
                <div class="logo">
                    <div class="logo-icon">💳</div>
                </div>
                <h2>Complete Payment</h2>
                <div class="amount">₹\(String(format: "%.2f", order.amount))</div>
                
                <div class="details">
                    <div class="detail-row">
                        <span class="detail-label">Order ID</span>
                        <span class="detail-value">\(order.orderId.prefix(12))...</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Merchant</span>
                        <span class="detail-value">\(RazorpayConfig.companyName)</span>
                    </div>
                </div>
                
                <form id="paymentForm">
                    <div class="form-group">
                        <label>Card Number</label>
                        <input type="tel" id="cardNumber" placeholder="4111 1111 1111 1111" maxlength="19" value="4111 1111 1111 1111">
                    </div>
                    <div class="card-row">
                        <div class="form-group">
                            <label>Expiry</label>
                            <input type="tel" id="expiry" placeholder="MM/YY" maxlength="5" value="12/25">
                        </div>
                        <div class="form-group">
                            <label>CVV</label>
                            <input type="tel" id="cvv" placeholder="123" maxlength="3" value="123">
                        </div>
                    </div>
                    <button type="submit">Pay ₹\(String(format: "%.2f", order.amount))</button>
                </form>
                
                <div class="test-info">
                    🧪 Test Mode: Use card 4111 1111 1111 1111
                </div>
                
                <div class="secured">
                    🔒 Secured by Razorpay
                </div>
            </div>
            
            <script>
                document.getElementById('paymentForm').addEventListener('submit', function(e) {
                    e.preventDefault();
                    
                    // Simulate payment processing
                    const button = document.querySelector('button');
                    button.textContent = 'Processing...';
                    button.disabled = true;
                    
                    setTimeout(function() {
                        // Generate a test payment ID
                        const paymentId = 'pay_test_' + Math.random().toString(36).substr(2, 9);
                        window.location.href = 'payment://success?payment_id=' + paymentId;
                    }, 1500);
                });
                
                // Auto-format card number
                document.getElementById('cardNumber').addEventListener('input', function(e) {
                    let value = e.target.value.replace(/\\s/g, '');
                    let formattedValue = value.match(/.{1,4}/g)?.join(' ') || value;
                    e.target.value = formattedValue;
                });
                
                // Auto-format expiry
                document.getElementById('expiry').addEventListener('input', function(e) {
                    let value = e.target.value.replace(/\\D/g, '');
                    if (value.length >= 2) {
                        value = value.substr(0, 2) + '/' + value.substr(2, 2);
                    }
                    e.target.value = value;
                });
            </script>
        </body>
        </html>
        """
        
        // Convert HTML to data URL
        if let data = checkoutHTML.data(using: .utf8) {
            let base64 = data.base64EncodedString()
            return URL(string: "data:text/html;base64,\(base64)")
        }
        
        return nil
    }
}

// MARK: - Models

struct PaymentOrder {
    let orderId: String
    let amount: Double
    let currency: String
}

struct Payment: Codable {
    var id: UUID?
    var userId: UUID
    var courseId: UUID
    var razorpayOrderId: String
    var razorpayPaymentId: String?
    var amount: Double
    var currency: String
    var status: PaymentStatus
    var createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case courseId = "course_id"
        case razorpayOrderId = "razorpay_order_id"
        case razorpayPaymentId = "razorpay_payment_id"
        case amount
        case currency
        case status
        case createdAt = "created_at"
    }
}

enum PaymentStatus: String, Codable {
    case pending = "pending"
    case success = "success"
    case failed = "failed"
}
