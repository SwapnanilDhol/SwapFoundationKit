/****************************************************************************
 * TextFieldExamplesView.swift
 * SwapFoundationKitHost
 *****************************************************************************/

import SwapFoundationKit
import SwiftUI

struct TextFieldExamplesView: View {
    @State private var name = ""
    @State private var email = "wrong address"
    @State private var password = ""
    @State private var search = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                exampleSection(
                    title: "Standard",
                    detail: "Labels, semantic content types, focus binding, and supporting copy."
                ) {
                    SFKTextField(
                        "Name",
                        text: $name,
                        prompt: "Optional",
                        leadingSystemImage: "person"
                    )
                    .sfkSupportingText("Used only when a reply should feel personal.")
                }

                exampleSection(
                    title: "Validation",
                    detail: "Error and success states are part of the primitive."
                ) {
                    SFKTextField(
                        "Email",
                        text: $email,
                        prompt: "you@example.com",
                        leadingSystemImage: "envelope"
                    )
                    .sfkInput(.email)
                    .sfkStatus(.error("Enter a valid email address."))
                    .sfkSupportingText("Use the address associated with your account.")
                }

                exampleSection(
                    title: "Secure entry",
                    detail: "Secure fields include a standard reveal control."
                ) {
                    SFKTextField(
                        "Password",
                        text: $password,
                        prompt: "Required",
                        leadingSystemImage: "lock"
                    )
                    .sfkInput(.password)
                    .sfkSupportingText("Use at least eight characters.")
                }

                exampleSection(
                    title: "Accessories",
                    detail: "Apps can supply consistent leading and trailing actions."
                ) {
                    SFKTextField(
                        "Search",
                        text: $search,
                        prompt: "Airport or city",
                        leadingSystemImage: "magnifyingglass"
                    )
                    .sfkTrailingAction(
                        systemImage: "xmark.circle.fill",
                        accessibilityLabel: "Clear search"
                    ) { search = "" }
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Text Fields")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func exampleSection<Content: View>(
        title: String,
        detail: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            content()
        }
    }
}

#Preview {
    NavigationStack {
        TextFieldExamplesView()
    }
}
