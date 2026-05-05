import SwiftUI
import SwiftData
import WidgetKit
import PhotosUI

struct AddEventSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var storeKitManager: StoreKitManager
    
    var eventToEdit: DayEvent?
    
    @State private var title: String
    @State private var targetDate: Date
    @State private var selectedThemeHex: String
    @State private var selectedIcon: String
    @State private var notes: String
    @State private var timerPreference: Int
    
    @State private var tempMediaFileNames: [String]
    @State private var loadedImages: [UIImage] = []
    
    @State private var showingCamera = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    let icons = ["star.fill", "heart.fill", "calendar", "airplane", "gift.fill", "graduationcap.fill", "briefcase.fill", "house.fill"]
    
    init(eventToEdit: DayEvent? = nil) {
        self.eventToEdit = eventToEdit
        _title = State(initialValue: eventToEdit?.title ?? "")
        _targetDate = State(initialValue: eventToEdit?.targetDate ?? Date().addingTimeInterval(86400))
        _selectedThemeHex = State(initialValue: eventToEdit?.themeColorHex ?? Theme.modernPastels[0])
        _selectedIcon = State(initialValue: eventToEdit?.iconName ?? "star.fill")
        _notes = State(initialValue: eventToEdit?.notes ?? "")
        _timerPreference = State(initialValue: eventToEdit?.timerPreference ?? 0)
        _tempMediaFileNames = State(initialValue: eventToEdit?.mediaFileNames ?? [])
    }
    
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card Preview
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PREVIEW")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                            .padding(.leading)
                        
                        let tempEvent = DayEvent(title: title, targetDate: targetDate, themeColorHex: selectedThemeHex, iconName: selectedIcon)
                        EventCardView(event: tempEvent)
                            .padding(.horizontal)
                    }
                    .padding(.top)

                    // 1. Details Section
                    VStack(spacing: 12) {
                        CustomTextField(placeholder: "Event Title", text: $title)
                        
                        DatePicker("Target Date", selection: $targetDate, displayedComponents: [.date, .hourAndMinute])
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // 2. MEMORIES & SHARING (Moved up as requested)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("MEMORIES & SHARING")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        // Prominent Share Button
                        // Note: For sharing, we use the temporary values to ensure the latest edits are shared
                        let renderEvent = eventToEdit ?? DayEvent(title: title, targetDate: targetDate, themeColorHex: selectedThemeHex, iconName: selectedIcon)
                        if let imageToShare = ShareHelper.renderEventCard(for: renderEvent, title: title, targetDate: targetDate, themeColorHex: selectedThemeHex, iconName: selectedIcon) {
                            ShareLink(item: Image(uiImage: imageToShare), preview: SharePreview(title, image: Image(uiImage: imageToShare))) {
                                HStack {
                                    Spacer()
                                    Label("SHARE TO SOCIAL", systemImage: "square.and.arrow.up")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .frame(height: 56)
                                .background(Color(hex: selectedThemeHex) ?? .blue)
                                .cornerRadius(16)
                                .shadow(color: (Color(hex: selectedThemeHex) ?? .blue).opacity(0.3), radius: 8, y: 4)
                            }
                        }

                        // Camera & Gallery Buttons
                        HStack(spacing: 12) {
                            Button {
                                showingCamera = true
                            } label: {
                                HStack {
                                    Image(systemName: "camera.fill")
                                    Text("Camera")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                            }
                            
                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                HStack {
                                    Image(systemName: "photo.on.rectangle")
                                    Text("Gallery")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        
                        if !loadedImages.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(loadedImages.indices, id: \.self) { index in
                                        Image(uiImage: loadedImages[index])
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .contextMenu {
                                                Button(role: .destructive) {
                                                    deleteImage(at: index)
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                    }
                                }
                            }
                            .frame(height: 110)
                        }
                    }
                    .padding(.horizontal)
                    
                    // 3. Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("NOTES")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        TextField("Write your thoughts here...", text: $notes, axis: .vertical)
                            .lineLimit(3...5)
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // 4. Appearance
                    VStack(alignment: .leading, spacing: 12) {
                        Text("APPEARANCE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Theme.modernPastels + Theme.darkAcademia, id: \.self) { hex in
                                    Circle()
                                        .fill(Color(hex: hex) ?? .blue)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary, lineWidth: selectedThemeHex == hex ? 3 : 0)
                                        )
                                        .onTapGesture {
                                            withAnimation {
                                                selectedThemeHex = hex
                                            }
                                        }
                                }
                            }
                        }
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 16) {
                            ForEach(icons, id: \.self) { icon in
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(selectedIcon == icon ? .white : .primary)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        selectedIcon == icon ? (Color(hex: selectedThemeHex) ?? .blue) : Color.clear
                                    )
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        withAnimation {
                                            selectedIcon = icon
                                        }
                                    }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // 5. Timer Style
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TIMER STYLE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        Picker("Style", selection: $timerPreference) {
                            Text("Auto").tag(0)
                            Text("Days").tag(1)
                            Text("Live").tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationTitle(eventToEdit == nil ? "New Event" : "Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveEvent() }
                        .disabled(!isFormValid)
                        .fontWeight(.bold)
                }
            }
            .sheet(isPresented: $showingCamera) {
                CameraPicker { image in
                    if let fileName = MediaManager.shared.saveImage(image) {
                        tempMediaFileNames.append(fileName)
                        loadedImages.append(image)
                    }
                }
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                        if let fileName = MediaManager.shared.saveImage(image) {
                            tempMediaFileNames.append(fileName)
                            loadedImages.append(image)
                        }
                    }
                    selectedPhotoItem = nil
                }
            }
            .onAppear {
                loadInitialImages()
            }
        }
    }
    
    private func loadInitialImages() {
        loadedImages = tempMediaFileNames.compactMap { MediaManager.shared.loadImage(fileName: $0) }
    }
    
    private func deleteImage(at index: Int) {
        let fileName = tempMediaFileNames[index]
        MediaManager.shared.deleteImage(fileName: fileName)
        tempMediaFileNames.remove(at: index)
        loadedImages.remove(at: index)
    }
    
    private func saveEvent() {
        if let event = eventToEdit {
            event.title = title
            event.targetDate = targetDate
            event.themeColorHex = selectedThemeHex
            event.iconName = selectedIcon
            event.notes = notes
            event.timerPreference = timerPreference
            event.mediaFileNames = tempMediaFileNames
        } else {
            let newEvent = DayEvent(
                title: title,
                targetDate: targetDate,
                themeColorHex: selectedThemeHex,
                iconName: selectedIcon,
                isPremium: true // Set to true since user is testing pro features
            )
            newEvent.notes = notes
            newEvent.timerPreference = timerPreference
            newEvent.mediaFileNames = tempMediaFileNames
            modelContext.insert(newEvent)
        }
        
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
        dismiss()
    }
}

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(12)
            .font(.headline)
    }
}
