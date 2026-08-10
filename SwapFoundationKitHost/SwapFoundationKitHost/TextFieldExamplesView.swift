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
    @State private var nameIsFocused = false

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
                        placeholder: "Optional",
                        leadingSystemImage: "person",
                        supportingText: "Used only when a reply should feel personal.",
                        contentType: .name,
                        textInputAutocapitalization: .words,
                        isFocused: $nameIsFocused
                    )
                }

                exampleSection(
                    title: "Validation",
                    detail: "Error and success states are part of the primitive."
                ) {
                    SFKTextField(
                        "Email",
                        text: $email,
                        placeholder: "you@example.com",
                        leadingSystemImage: "envelope",
                        status: .error("Enter a valid email address."),
                        keyboardType: .emailAddress,
                        contentType: .emailAddress,
                        textInputAutocapitalization: .never,
                        autocorrectionDisabled: true
                    )
                }

                exampleSection(
                    title: "Secure entry",
                    detail: "Secure fields include a standard reveal control."
                ) {
                    SFKTextField(
                        "Password",
                        text: $password,
                        placeholder: "Required",
                        leadingSystemImage: "lock",
                        supportingText: "Use at least eight characters.",
                        isSecure: true,
                        contentType: .newPassword
                    )
                }

                exampleSection(
                    title: "Accessories",
                    detail: "Apps can supply consistent leading and trailing actions."
                ) {
                    SFKTextField(
                        "Search",
                        text: $search,
                        placeholder: "Airport or city",
                        leadingSystemImage: "magnifyingglass",
                        trailingSystemImage: "xmark.circle.fill",
                        trailingAccessibilityLabel: "Clear search",
                        onTrailingAction: { search = "" }
                    )
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
