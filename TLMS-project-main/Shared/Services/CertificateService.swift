//
//  CertificateService.swift
//  TLMS-project-main
//
//  Service for managing course completion certificates
//

import Foundation
import Supabase
import Combine

@MainActor
class CertificateService: ObservableObject {
    private let supabase: SupabaseClient
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    init() {
        self.supabase = SupabaseManager.shared.client
    }
    
    // MARK: - Generate Certificate
    
    func generateCertificate(
        userId: UUID,
        courseId: UUID,
        userName: String,
        courseName: String,
        instructorName: String
    ) async -> Certificate? {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // Check if certificate already exists
            let existing: [Certificate.DatabaseModel] = try await supabase
                .from("certificates")
                .select()
                .eq("user_id", value: userId)
                .eq("course_id", value: courseId)
                .execute()
                .value
            
            if let existingCert = existing.first {
                return existingCert.toCertificate()
            }
            
            // Generate new certificate
            let certificateNumber = Certificate.generateCertificateNumber()
            let now = ISO8601DateFormatter().string(from: Date())
            
            let newCertificate = Certificate.DatabaseModel(
                id: UUID(),
                user_id: userId,
                course_id: courseId,
                user_name: userName,
                course_name: courseName,
                completion_date: now,
                certificate_number: certificateNumber,
                instructor_name: instructorName,
                created_at: now
            )
            
            let inserted: [Certificate.DatabaseModel] = try await supabase
                .from("certificates")
                .insert(newCertificate)
                .select()
                .execute()
                .value
            
            guard let certificate = inserted.first else {
                errorMessage = "Failed to generate certificate"
                return nil
            }
            
            print("✅ Certificate generated: \(certificate.certificate_number)")
            return certificate.toCertificate()
            
        } catch {
            print("❌ Error generating certificate: \(error)")
            errorMessage = "Failed to generate certificate: \(error.localizedDescription)"
            return nil
        }
    }
    
    // MARK: - Fetch Certificates
    
    func fetchCertificates(userId: UUID) async -> [Certificate] {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // Fetch certificates and join with courses to filter out deleted/unpublished courses
            let certificates: [Certificate.DatabaseModel] = try await supabase
                .from("certificates")
                .select("""
                    *,
                    courses!inner(status)
                """)
                .eq("user_id", value: userId)
                .eq("courses.status", value: "published")
                .order("created_at", ascending: false)
                .execute()
                .value
            
            print("✅ Fetched \(certificates.count) certificates for published courses")
            return certificates.map { $0.toCertificate() }
            
        } catch {
            print("❌ Error fetching certificates: \(error)")
            errorMessage = "Failed to fetch certificates: \(error.localizedDescription)"
            return []
        }
    }
    
    // MARK: - Verify Certificate
    
    func verifyCertificate(certificateNumber: String) async -> Certificate? {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let certificates: [Certificate.DatabaseModel] = try await supabase
                .from("certificates")
                .select()
                .eq("certificate_number", value: certificateNumber)
                .execute()
                .value
            
            guard let certificate = certificates.first else {
                errorMessage = "Certificate not found"
                return nil
            }
            
            return certificate.toCertificate()
            
        } catch {
            print("❌ Error verifying certificate: \(error)")
            errorMessage = "Failed to verify certificate: \(error.localizedDescription)"
            return nil
        }
    }
    
    // MARK: - Check Eligibility
    
    func checkCertificateEligibility(userId: UUID, courseId: UUID) async -> Bool {
        do {
            // Check if course is 100% complete
            let enrollments: [Enrollment] = try await supabase
                .from("enrollments")
                .select()
                .eq("user_id", value: userId)
                .eq("course_id", value: courseId)
                .execute()
                .value
            
            guard let enrollment = enrollments.first else {
                return false
            }
            
            // Certificate eligible if progress is 100%
            return enrollment.progress! >= 1.0
            
        } catch {
            print("❌ Error checking eligibility: \(error)")
            return false
        }
    }
}
