import PhotosUI
import SwapFoundationKit
import SwiftUI

struct SFKFeedbackView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ObservedObject var viewModel: SFKFeedbackViewModel
    let configuration: SFKFeedbackConfiguration
    @FocusState private var focusedField: Field?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoLoadingTask: Task<Void, Never>?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                introduction
                categorySection
                messageSection
                attachmentSection
                contactSection
                privacyCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Send Feedback")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .onAppear(perform: viewModel.onAppear)
        .onDisappear { photoLoadingTask?.cancel() }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { submitAction }
        }
    }

    private var introduction: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(configuration.copy.introductionTitle)
                .font(.title2.weight(.bold))
                .tracking(-0.3)
            Text(configuration.copy.introductionMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("What’s this about?")
            SFKChipFlowLayout(spacing: 8) {
                ForEach(SFKFeedbackCategory.allCases) { category in
                    SFKSelectableChip(
                        category.label,
                        icon: category.icon,
                        isSelected: viewModel.category == category,
                        tintColor: category.tintColor
                    ) { viewModel.category = category }
                    .accessibilityIdentifier("feedbackCategory.\(category.rawValue)")
                }
            }
        }
    }

    private var messageSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                sectionTitle("Your message")
                Spacer()
                Text("\(viewModel.remainingCharacters)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(viewModel.remainingCharacters < 0 ? .red : .secondary)
            }
            ZStack(alignment: .topLeading) {
                if viewModel.message.isEmpty {
                    Text("What happened, or what should I build?")
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $viewModel.message)
                    .focused($focusedField, equals: .message)
                    .frame(minHeight: 150)
                    .padding(10)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .accessibilityIdentifier("feedbackMessageField")
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(messageBorderColor, lineWidth: focusedField == .message ? 1.5 : 1)
            }
            .animation(fieldAnimation, value: focusedField)
            if shouldShowMessageError {
                validationMessage("Enter at least 4 characters and keep your message under 2,000.")
            }
        }
    }

    private var attachmentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Add an image")
            if let attachment = viewModel.attachment,
               let image = UIImage(data: attachment.data) {
                SFKCard(cornerRadius: 16, backgroundFill: Color(.secondarySystemGroupedBackground), padding: 12) {
                    HStack(spacing: 12) {
                        Image(uiImage: image)
                            .resizable().scaledToFill().frame(width: 72, height: 72)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Image attached").font(.subheadline.weight(.semibold))
                            Text(ByteCountFormatter.string(fromByteCount: Int64(attachment.data.count), countStyle: .file))
                                .font(.caption).foregroundStyle(.secondary)
                                SFKButton("Remove", role: .destructive) {
                                    selectedPhoto = nil
                                    viewModel.removeAttachment()
                                }
                                .sfkIcon("trash")
                                .sfkFullWidth(false)
                                .sfkControlSize(.small)
                        }
                        Spacer(minLength: 0)
                    }
                }
            } else if viewModel.isProcessingAttachment {
                HStack(spacing: 10) { ProgressView(); Text("Preparing image…") }
                    .frame(maxWidth: .infinity, minHeight: 44)
            } else {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label("Choose an image", systemImage: "photo.badge.plus")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.bordered)
                .tint(configuration.accentColor)
                .disabled(viewModel.isSubmitting)
                .accessibilityIdentifier("feedbackImagePicker")
            }
            Text(attachmentDisclosure)
                .font(.footnote).foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if let error = viewModel.attachmentErrorMessage { validationMessage(error) }
        }
        .onChange(of: selectedPhoto) { _, photo in
            photoLoadingTask?.cancel()
            guard let photo else { return }
            let requestID = viewModel.beginAttachmentProcessing()
            photoLoadingTask = Task {
                do {
                    guard let data = try await photo.loadTransferable(type: Data.self) else {
                        viewModel.failToLoadAttachment(requestID: requestID)
                        return
                    }
                    try Task.checkCancellation()
                    viewModel.attachImage(data, requestID: requestID)
                } catch is CancellationError {
                    return
                } catch {
                    viewModel.failToLoadAttachment(requestID: requestID)
                }
            }
        }
    }

    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("About you")
            SFKTextField("Name", text: $viewModel.name, prompt: "Optional", leadingSystemImage: "person")
                .sfkStatus(nameFieldStatus)
                .sfkTint(configuration.accentColor)
                .sfkInput(.init(contentType: .name, textInputAutocapitalization: .words,
                                autocorrectionDisabled: true, submitLabel: .next))
                .sfkFocused(focusBinding(for: .name))
                .sfkOnSubmit { focusedField = .email }
                .accessibilityIdentifier("feedbackNameField")
            SFKTextField(
                "Email", text: $viewModel.replyEmail, prompt: "Optional",
                leadingSystemImage: "envelope"
            )
            .sfkStatus(emailFieldStatus)
            .sfkTint(configuration.accentColor)
            .sfkInput(.email)
            .sfkFocused(focusBinding(for: .email))
            .sfkOnSubmit { focusedField = nil }
            .accessibilityIdentifier("feedbackEmailField")
            Text("Optional. Add these only if you’d like me to reply.")
                .font(.footnote).foregroundStyle(.secondary)
        }
    }

    private var privacyCard: some View {
        SFKCard(
            cornerRadius: 16,
            backgroundFill: Color(.secondarySystemGroupedBackground),
            icon: "hand.raised.fill",
            iconTint: configuration.accentColor,
            padding: 14
        ) {
            VStack(alignment: .leading, spacing: 5) {
                Text("What gets shared").font(.subheadline.weight(.semibold))
                Text(configuration.copy.privacyMessage)
                    .font(.footnote).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var submitAction: some View {
        SFKButton("Send", role: .borderless) {
            focusedField = nil
            viewModel.submit()
        }
        .sfkIcon("paperplane.fill")
        .sfkLoading(viewModel.isSubmitting)
        .sfkTint(configuration.accentColor)
        .disabled(!viewModel.canSubmit)
        .tint(configuration.accentColor)
        .accessibilityLabel("Send Feedback")
        .accessibilityIdentifier("feedbackSubmitButton")
    }

    private var attachmentDisclosure: String {
        if let days = configuration.copy.attachmentRetentionDays {
            return "Optional. One image is compressed before upload and removed after \(days) days."
        }
        return "Optional. One image is compressed before upload."
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title).font(.subheadline.weight(.semibold))
    }

    private func validationMessage(_ message: String) -> some View {
        Label(message, systemImage: "exclamationmark.circle.fill")
            .font(.caption).foregroundStyle(.red)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var fieldAnimation: Animation? {
        reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 1)
    }

    private var messageBorderColor: Color {
        if shouldShowMessageError { return .red.opacity(0.75) }
        return focusedField == .message
            ? configuration.accentColor.opacity(0.65)
            : .secondary.opacity(0.14)
    }

    private var shouldShowMessageError: Bool {
        !viewModel.message.isEmpty && !viewModel.isMessageValid && focusedField != .message
    }

    private var nameFieldStatus: SFKTextFieldStatus {
        !viewModel.isNameValid && focusedField != .name
            ? .error("Keep your name under 120 characters.") : .normal
    }

    private var emailFieldStatus: SFKTextFieldStatus {
        !viewModel.isReplyEmailValid && focusedField != .email
            ? .error("Enter a valid email address or leave this blank.") : .normal
    }

    private func focusBinding(for field: Field) -> Binding<Bool> {
        Binding(
            get: { focusedField == field },
            set: { isFocused in
                if isFocused {
                    focusedField = field
                } else if focusedField == field {
                    focusedField = nil
                }
            }
        )
    }

    private enum Field: Hashable { case message, name, email }
}

private extension SFKFeedbackCategory {
    var label: String {
        switch self {
        case .feedback: "Feedback"
        case .bug: "Bug"
        case .idea: "Idea"
        }
    }
    var icon: String {
        switch self {
        case .feedback: "bubble.left.and.text.bubble.right.fill"
        case .bug: "ladybug.fill"
        case .idea: "lightbulb.fill"
        }
    }
    var tintColor: Color {
        switch self {
        case .feedback: .blue
        case .bug: .red
        case .idea: .orange
        }
    }
}
