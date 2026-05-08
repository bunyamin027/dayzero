import EventKit
import SwiftUI
import SwiftData
import WidgetKit

// MARK: - Mesh Gradient Background
struct MeshGradientBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.95, blue: 0.98).ignoresSafeArea()
            Circle()
                .fill(Color(hex: "#C084FC")!.opacity(0.18))
                .frame(width: 340)
                .blur(radius: 80)
                .offset(x: 60, y: -80)
            Circle()
                .fill(Color(hex: "#818CF8")!.opacity(0.14))
                .frame(width: 280)
                .blur(radius: 70)
                .offset(x: -40, y: 140)
            Circle()
                .fill(Color(hex: "#F0ABFC")!.opacity(0.12))
                .frame(width: 200)
                .blur(radius: 60)
                .offset(x: -30, y: 300)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Hero Preview Card
struct HeroPosterCard: View {
    let event: DayEvent

    var daysRemaining: Int {
        let cal = Calendar.current
        let components = cal.dateComponents([.day], from: cal.startOfDay(for: Date()), to: cal.startOfDay(for: event.targetDate))
        return components.day ?? 0
    }

    private func getFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch event.fontStyle {
        case "Serif":       return .system(size: size, weight: weight, design: .serif)
        case "Rounded":     return .system(size: size, weight: weight, design: .rounded)
        case "Retro":       return .custom("Courier", size: size).weight(weight)
        case "Typewriter":  return .custom("AmericanTypewriter", size: size).weight(weight)
        default:            return .system(size: size, weight: weight)
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Card background with theme gradient
                RoundedRectangle(cornerRadius: 36, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [event.themeColor.opacity(0.85), event.themeColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Decorative circles
                Circle()
                    .fill(.white.opacity(0.08))
                    .frame(width: 220)
                    .offset(x: 80, y: -60)
                Circle()
                    .fill(.white.opacity(0.05))
                    .frame(width: 160)
                    .offset(x: -70, y: 90)

                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(event.targetDate, format: .dateTime.day().month().year())
                            .font(getFont(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(.white.opacity(0.15)))
                        Spacer()
                        Image(systemName: event.iconName)
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                    }

                    Spacer()

                    Text(event.title.isEmpty ? "Event Preview" : event.title)
                        .font(getFont(size: 30, weight: .black))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.6)

                    Spacer().frame(height: 16)

                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(abs(daysRemaining))")
                            .font(getFont(size: 72, weight: .black))
                            .foregroundColor(.white)
                        Text(daysRemaining >= 0 ? "DAYS\nLEFT" : "DAYS\nAGO")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(28)
            }
        }
        .frame(height: UIScreen.main.bounds.height * 0.38)
        .shadow(color: event.themeColor.opacity(0.35), radius: 28, x: 0, y: 14)
        .shadow(color: event.themeColor.opacity(0.18), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Typography Block (Asymmetric)
struct TypographyFloatingBlock: View {
    let fontName: String
    let isSelected: Bool
    let isPro: Bool
    let isUnlocked: Bool
    let action: () -> Void

    private var displayFont: Font {
        switch fontName {
        case "Serif":       return .system(size: 22, weight: .black, design: .serif)
        case "Rounded":     return .system(size: 22, weight: .black, design: .rounded)
        case "Retro":       return .custom("Courier", size: 22).weight(.bold)
        case "Typewriter":  return .custom("AmericanTypewriter", size: 20).weight(.bold)
        default:            return .system(size: 22, weight: .black)
        }
    }

    // Give each font a distinct height to feel asymmetric
    private var cardHeight: CGFloat {
        switch fontName {
        case "Serif":       return 108
        case "Rounded":     return 92
        case "Retro":       return 116
        case "Typewriter":  return 100
        default:            return 96
        }
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(
                                isSelected ? Color(hex: "#818CF8")!.opacity(0.9) : Color.clear,
                                lineWidth: 2.5
                            )
                    )

                if isSelected {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color(hex: "#818CF8")!.opacity(0.08))
                }

                VStack(spacing: 6) {
                    Text(fontName)
                        .font(displayFont)
                        .foregroundColor(isSelected ? Color(hex: "#4F46E5")! : .primary)
                        .lineLimit(1)
                    Text("Aa")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                }

                if isPro && !isUnlocked {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "lock.fill")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white)
                                .padding(5)
                                .background(Circle().fill(Color(hex: "#F59E0B")!))
                                .offset(x: 4, y: -4)
                        }
                        Spacer()
                    }
                }
            }
            .frame(width: 100, height: cardHeight)
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.04 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.65), value: isSelected)
        .shadow(color: isSelected ? Color(hex: "#818CF8")!.opacity(0.3) : .black.opacity(0.07), radius: isSelected ? 16 : 8, x: 0, y: isSelected ? 8 : 4)
    }
}

// MARK: - Masonry Pin Card (generic)
struct PinCard<Content: View>: View {
    let content: Content
    var height: CGFloat = 180
    var accent: Color = Color(hex: "#818CF8")!

    init(height: CGFloat = 180, accent: Color = Color(hex: "#818CF8")!, @ViewBuilder content: () -> Content) {
        self.height = height
        self.accent = accent
        self.content = content()
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(.white.opacity(0.6), lineWidth: 1)
                )
            content
        }
        .frame(height: height)
        .shadow(color: accent.opacity(0.13), radius: 20, x: 0, y: 10)
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Milestone Mini Row
struct MilestoneMiniRow: View {
    @Bindable var task: EventTask
    var body: some View {
        HStack(spacing: 10) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { task.isCompleted.toggle() }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } label: {
                ZStack {
                    Circle()
                        .strokeBorder(task.isCompleted ? Color(hex: "#10B981")! : Color.secondary.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 20, height: 20)
                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Color(hex: "#10B981")!)
                    }
                }
            }
            Text(task.title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(task.isCompleted ? .secondary : .primary)
                .strikethrough(task.isCompleted)
                .lineLimit(1)
            Spacer()
        }
    }
}

struct MilestonePill: View {
    @Bindable var task: EventTask
    var themeColor: Color = .blue

    var body: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { 
                    task.isCompleted.toggle() 
                }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } label: {
                ZStack {
                    Circle()
                        .strokeBorder(task.isCompleted ? Color(hex: "#10B981")! : Color.secondary.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                    
                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: "#10B981")!)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .buttonStyle(.plain)

            Text(task.title)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(task.isCompleted ? .secondary.opacity(0.7) : .primary)
                .strikethrough(task.isCompleted)
                .lineLimit(2)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(task.isCompleted ? Color(hex: "#10B981")!.opacity(0.2) : themeColor.opacity(0.2), lineWidth: 1)
        )
        .blur(radius: task.isCompleted ? 0.8 : 0)
        .opacity(task.isCompleted ? 0.6 : 1.0)
        .scaleEffect(task.isCompleted ? 0.98 : 1.0)
    }
}

// MARK: - AddEventSheet (UnifiedEditorView)
struct AddEventSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var storeKitManager: StoreKitManager

    var eventToEdit: DayEvent?

    @State private var title: String
    @State private var targetDate: Date
    @State private var notes: String
    @State private var selectedThemeHex: String
    @State private var selectedIcon: String
    @State private var newTaskTitle = ""
    @State private var showingPaywall = false
    @State private var selectedFontStyle: String
    @State private var notesExpanded = false
    @State private var tempTasks: [String] = []
    @FocusState private var notesFocused: Bool
    @FocusState private var taskInputFocused: Bool

    init(eventToEdit: DayEvent? = nil) {
        self.eventToEdit = eventToEdit
        _title = State(initialValue: eventToEdit?.title ?? "")
        _targetDate = State(initialValue: eventToEdit?.targetDate ?? Date().addingTimeInterval(86400))
        _notes = State(initialValue: eventToEdit?.notes ?? "")
        _selectedThemeHex = State(initialValue: eventToEdit?.themeColorHex ?? Theme.modernPastels[0])
        _selectedIcon = State(initialValue: eventToEdit?.iconName ?? "star.fill")
        _selectedFontStyle = State(initialValue: eventToEdit?.fontStyle ?? "Classic")
    }

    private let fonts = ["Classic", "Serif", "Rounded", "Retro", "Typewriter"]

    var previewEvent: DayEvent {
        let e = DayEvent(title: title.isEmpty ? "Event Preview" : title, targetDate: targetDate, themeColorHex: selectedThemeHex, iconName: selectedIcon)
        e.fontStyle = selectedFontStyle
        return e
    }

    var body: some View {
        ZStack {
                MeshGradientBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        // ── HERO: Full-bleed Live Preview ────────────────
                        HeroPosterCard(event: previewEvent)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: title)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedFontStyle)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedThemeHex)

                        // ── TITLE & DATE INPUT ───────────────────────────
                        VStack(spacing: 12) {
                            TextField("Event Name", text: $title)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .padding(16)
                                .background(.ultraThinMaterial)
                                .continuousCorner(radius: 20)
                                .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 5)

                            DatePicker("", selection: $targetDate, displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                                .datePickerStyle(.compact)
                                .padding(14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.ultraThinMaterial)
                                .continuousCorner(radius: 20)
                                .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 5)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)

                        // ── MILESTONES (Inline Dynamic List) ───────────────────
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("MILESTONES")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundColor(.secondary)
                                    .tracking(2)
                                Spacer()
                                if !storeKitManager.isPro {
                                    HStack(spacing: 4) {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 10))
                                        Text("PRO")
                                            .font(.system(size: 10, weight: .black))
                                    }
                                    .foregroundColor(Color(hex: "#F59E0B")!)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Capsule().fill(Color(hex: "#FEF3C7")!))
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Task Input
                            HStack {
                                Image(systemName: "flag.fill")
                                    .foregroundColor(Color(hex: selectedThemeHex) ?? Color(hex: "#818CF8")!)
                                TextField("Add a milestone...", text: $newTaskTitle)
                                    .focused($taskInputFocused)
                                    .onSubmit { addMilestone() }
                                Button { addMilestone() } label: {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(newTaskTitle.isEmpty ? .secondary : (Color(hex: selectedThemeHex) ?? Color(hex: "#818CF8")!))
                                }
                                .disabled(newTaskTitle.isEmpty)
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(.ultraThinMaterial)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .strokeBorder(Color(hex: selectedThemeHex)!.opacity(0.4), lineWidth: 1.5)
                            )
                            .padding(.horizontal, 16)
                            
                            // Tasks List (Existing)
                            if let event = eventToEdit {
                                let tasks = (event.tasks ?? []).sorted { $0.createdAt < $1.createdAt }
                                LazyVStack(spacing: 8) {
                                    ForEach(tasks) { task in
                                        MilestonePill(task: task, themeColor: Color(hex: selectedThemeHex) ?? .blue)
                                            .padding(.horizontal, 16)
                                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                                Button(role: .destructive) {
                                                    withAnimation(.spring()) {
                                                        modelContext.delete(task)
                                                        try? modelContext.save()
                                                    }
                                                } label: {
                                                    Label("Delete", systemImage: "trash.fill")
                                                }
                                            }
                                    }
                                }
                                .padding(.top, 4)
                            } else {
                                // Tasks List (Temp for new events)
                                LazyVStack(spacing: 8) {
                                    ForEach(tempTasks, id: \.self) { taskTitle in
                                        HStack(spacing: 12) {
                                            Image(systemName: "circle")
                                                .foregroundColor(.secondary.opacity(0.4))
                                                .frame(width: 22, height: 22)
                                            
                                            Text(taskTitle)
                                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                                .foregroundColor(.primary)
                                            
                                            Spacer()
                                            
                                            Button {
                                                withAnimation(.spring()) {
                                                    tempTasks.removeAll { $0 == taskTitle }
                                                }
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.secondary.opacity(0.3))
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
                                        .padding(.horizontal, 16)
                                    }
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding(.top, 16)

                        // ── ICON SCROLLER ────────────────────────────────
                        IconScroller(selectedIcon: $selectedIcon, themeColor: Color(hex: selectedThemeHex) ?? .blue)

                        // ── THEME COLOR SCROLLER ─────────────────────────
                        ThemeColorScroller(selectedThemeHex: $selectedThemeHex)

                        // ── TYPOGRAPHY SCROLLER ──────────────────────────
                        VStack(alignment: .leading, spacing: 10) {
                            Text("TYPOGRAPHY")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.secondary)
                                .tracking(2)
                                .padding(.horizontal, 20)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .bottom, spacing: 12) {
                                    ForEach(fonts, id: \.self) { font in
                                        let isPro = font != "Classic"
                                        TypographyFloatingBlock(
                                            fontName: font,
                                            isSelected: selectedFontStyle == font,
                                            isPro: isPro,
                                            isUnlocked: storeKitManager.isPro
                                        ) {
                                            if isPro && !storeKitManager.isPro {
                                                showingPaywall = true
                                            } else {
                                                selectedFontStyle = font
                                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                            }
                        }
                        .padding(.top, 8)

                        // ── NOTES (Expandable Icon) ─────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("NOTES")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundColor(.secondary)
                                    .tracking(2)
                                Spacer()
                                Button {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        notesExpanded.toggle()
                                        if notesExpanded { notesFocused = true }
                                    }
                                } label: {
                                    Image(systemName: notes.isEmpty ? "plus.bubble" : "bubble.left.and.text.bubble.right.fill")
                                        .font(.title3)
                                        .foregroundColor(notesExpanded || !notes.isEmpty ? Color(hex: "#F472B6")! : .secondary)
                                        .padding(8)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Circle())
                                }
                            }
                            
                            if notesExpanded || !notes.isEmpty {
                                TextEditor(text: $notes)
                                    .focused($notesFocused)
                                    .frame(minHeight: 100)
                                    .padding(12)
                                    .scrollContentBackground(.hidden)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .fill(.ultraThinMaterial)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .strokeBorder(Color(hex: selectedThemeHex)!.opacity(0.4), lineWidth: 1.5)
                                    )
                                    .shadow(color: Color(hex: selectedThemeHex)!.opacity(0.15), radius: 12, x: 0, y: 6)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)


                        Spacer(minLength: 100)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationTitle(eventToEdit == nil ? "New Event" : "Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .font(.system(size: 15, weight: .medium))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        saveEvent()
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    } label: {
                        Text("Save")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 7)
                            .background(
                                Capsule()
                                    .fill(
                                        title.isEmpty
                                        ? AnyShapeStyle(Color.secondary.opacity(0.3))
                                        : AnyShapeStyle(LinearGradient(colors: [Color(hex: "#4F46E5")!, Color(hex: "#7C3AED")!], startPoint: .leading, endPoint: .trailing))
                                    )
                            )
                    }
                    .disabled(title.isEmpty)
                }
            }
            .sheet(isPresented: $showingPaywall) { PaywallView() }
    }

    private func addMilestone() {
        guard !newTaskTitle.isEmpty else { return }
        guard storeKitManager.isPro else { showingPaywall = true; return }
        
        if let event = eventToEdit {
            let task = EventTask(title: newTaskTitle)
            task.event = event
            modelContext.insert(task)
        } else {
            tempTasks.append(newTaskTitle)
        }
        newTaskTitle = ""
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func saveEvent() {
        if let event = eventToEdit {
            event.title = title
            event.targetDate = targetDate
            event.notes = notes
            event.themeColorHex = selectedThemeHex
            event.iconName = selectedIcon
            event.fontStyle = selectedFontStyle
        } else {
            let newEvent = DayEvent(title: title, targetDate: targetDate, themeColorHex: selectedThemeHex, iconName: selectedIcon)
            newEvent.notes = notes
            newEvent.fontStyle = selectedFontStyle
            modelContext.insert(newEvent)
            
            // Save temporary milestones
            for taskTitle in tempTasks {
                let task = EventTask(title: taskTitle)
                task.event = newEvent
                modelContext.insert(task)
            }
        }
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
        dismiss()
    }
}


struct ThemeColorScroller: View {
    @Binding var selectedThemeHex: String
    private let themes = Theme.modernPastels + Theme.darkAcademia

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(themes, id: \.self) { hex in
                    let color = Color(hex: hex) ?? .blue
                    let isSelected = selectedThemeHex == hex
                    
                    Circle()
                        .fill(color)
                        .frame(width: isSelected ? 38 : 30, height: isSelected ? 38 : 30)
                        .overlay(Circle().strokeBorder(.white, lineWidth: isSelected ? 3 : 0))
                        .shadow(color: color.opacity(0.5), radius: 6, x: 0, y: 3)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                selectedThemeHex = hex
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
    }
}

// MARK: - Icon Scroller
struct IconScroller: View {
    @Binding var selectedIcon: String
    var themeColor: Color
    
    private let icons = [
        "star.fill", "heart.fill", "gift.fill", "airplane", 
        "music.mic", "graduationcap.fill", "gamecontroller.fill", 
        "briefcase.fill", "book.closed.fill", "popcorn.fill", 
        "cup.and.saucer.fill", "figure.run", "car.fill", 
        "house.fill", "cart.fill", "party.popper.fill"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("ICON")
                .font(.system(size: 10, weight: .black))
                .foregroundColor(.secondary)
                .tracking(2)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(icons, id: \.self) { icon in
                        let isSelected = selectedIcon == icon
                        
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                selectedIcon = icon
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        } label: {
                            Image(systemName: icon)
                                .font(.system(size: 20))
                                .foregroundColor(isSelected ? .white : .primary)
                                .frame(width: 44, height: 44)
                                .background(
                                    ZStack {
                                        if isSelected {
                                            Circle().fill(themeColor)
                                        } else {
                                            Circle().fill(.ultraThinMaterial)
                                        }
                                    }
                                )
                                .scaleEffect(isSelected ? 1.1 : 1.0)
                                .shadow(color: isSelected ? themeColor.opacity(0.4) : .black.opacity(0.05), radius: 6, x: 0, y: 3)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
        }
    }
}


// MARK: - Calendar Import Restored (Advanced)
import EventKit
import SwiftData
import SwiftUI

@MainActor
class CalendarImportManager: ObservableObject {
    static let shared = CalendarImportManager()
    let eventStore = EKEventStore()
    
    @Published var availableCalendars: [EKCalendar] = []
    @Published var selectedCalendarIDs: Set<String> = []
    @Published var includeHolidays: Bool = false
    @Published var filterKeyword: String = ""
    
    @Published var fetchedEvents: [EKEvent] = []
    @Published var deselectedEventIDs: Set<String> = []
    
    var selectedEventsCount: Int {
        fetchedEvents.filter { !deselectedEventIDs.contains($0.eventIdentifier) }.count
    }
    
    func requestAccess() async {
        do {
            let granted: Bool
            if #available(iOS 17.0, *) {
                granted = try await eventStore.requestFullAccessToEvents()
            } else {
                granted = try await withCheckedThrowingContinuation { continuation in
                    eventStore.requestAccess(to: .event) { granted, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: granted)
                        }
                    }
                }
            }
            if granted {
                await fetchCalendars()
            }
        } catch {
            print("Calendar access denied: \(error.localizedDescription)")
        }
    }
    
    func fetchCalendars() async {
        let calendars = eventStore.calendars(for: .event)
        self.availableCalendars = calendars.sorted { $0.title < $1.title }
        if selectedCalendarIDs.isEmpty {
            selectedCalendarIDs = Set(calendars.map { $0.calendarIdentifier })
        }
    }
    
    func fetchSmartEvents(context: ModelContext) async {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .year, value: 1, to: startDate)!
        
        let calendars = eventStore.calendars(for: .event).filter { selectedCalendarIDs.contains($0.calendarIdentifier) }
        guard !calendars.isEmpty else {
            self.fetchedEvents = []
            return
        }
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        var events = eventStore.events(matching: predicate)
        
        // Filter holidays
        if !includeHolidays {
            events = events.filter { $0.calendar.type != .subscription && !$0.calendar.title.lowercased().contains("holiday") && !$0.calendar.title.lowercased().contains("tatil") }
        }
        
        // Filter keyword
        if !filterKeyword.isEmpty {
            let keyword = filterKeyword.lowercased()
            events = events.filter { $0.title.lowercased().contains(keyword) }
        }
        
        // Deep Deduplication & Filter existing
        var uniqueEvents: [EKEvent] = []
        var seenSignatures = Set<String>()
        
        // Fetch existing DayEvents to prevent duplicates
        let descriptor = FetchDescriptor<DayEvent>()
        let existingEvents = (try? context.fetch(descriptor)) ?? []
        
        for event in events {
            // Strip punctuation and spaces for deep deduplication
            let normalizedTitle = event.title.lowercased()
                .replacingOccurrences(of: "'", with: "")
                .replacingOccurrences(of: "’", with: "")
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "(publicholiday)", with: "")
                .replacingOccurrences(of: "(resmitatil)", with: "")
            
            let dateStr = DateFormatter.localizedString(from: event.startDate, dateStyle: .short, timeStyle: .none)
            let signature = "\(normalizedTitle)|\(dateStr)"
            
            if seenSignatures.contains(signature) {
                continue
            }
            
            // Check if already in DayZero
            let isAlreadyImported = existingEvents.contains { dayEvent in
                if let id = dayEvent.calendarEventIdentifier, id == event.eventIdentifier { return true }
                
                let dayEventNormalized = dayEvent.title.lowercased()
                    .replacingOccurrences(of: "'", with: "")
                    .replacingOccurrences(of: "’", with: "")
                    .replacingOccurrences(of: " ", with: "")
                
                let dayEventDateStr = DateFormatter.localizedString(from: dayEvent.targetDate, dateStyle: .short, timeStyle: .none)
                return dayEventNormalized == normalizedTitle && dayEventDateStr == dateStr
            }
            
            if !isAlreadyImported {
                seenSignatures.insert(signature)
                uniqueEvents.append(event)
            }
        }
        
        self.fetchedEvents = uniqueEvents.sorted { $0.startDate < $1.startDate }
        self.deselectedEventIDs.removeAll()
    }
}

struct SmartImportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var manager = CalendarImportManager.shared
    
    var body: some View {
        ZStack {
            // Tam Koyu Arka Plan
            Color.black.ignoresSafeArea()
            MeshGradientBackground().opacity(0.4)
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Image(systemName: "wand.and.stars")
                        .font(.title2)
                        .foregroundColor(.white)
                    Text("Smart Import")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        // 1. Holidays Card
                        ConfigCard(title: "PUBLIC HOLIDAYS", icon: "party.popper") {
                            HStack {
                                Text("Include Official Holidays")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                PremiumToggle(isOn: $manager.includeHolidays)
                            }
                        }
                        
                        // 2. Select Sources (Active Calendars)
                        ConfigCard(title: "SELECT SOURCES", icon: "calendar") {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(manager.availableCalendars, id: \.calendarIdentifier) { cal in
                                        let isSelected = manager.selectedCalendarIDs.contains(cal.calendarIdentifier)
                                        Button {
                                            if isSelected { manager.selectedCalendarIDs.remove(cal.calendarIdentifier) }
                                            else { manager.selectedCalendarIDs.insert(cal.calendarIdentifier) }
                                            UISelectionFeedbackGenerator().selectionChanged()
                                        } label: {
                                            HStack(spacing: 8) {
                                                Circle().fill(Color(cgColor: cal.cgColor)).frame(width: 10, height: 10)
                                                Text(cal.title).font(.system(size: 14, weight: .bold))
                                                if isSelected { Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)) }
                                            }
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 10)
                                            .background(isSelected ? Color(hex: "#4F46E5")! : Color.white.opacity(0.05))
                                            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(isSelected ? Color(hex: "#818CF8")! : Color.clear, lineWidth: 2))
                                            .foregroundColor(.white)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        
                        // 3. Dynamic List
                        VStack(alignment: .leading, spacing: 16) {
                            Text("FOUND EVENTS (\(manager.selectedEventsCount) SELECTED)")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.horizontal, 4)
                            
                            ForEach(manager.fetchedEvents, id: \.eventIdentifier) { event in
                                let isSelected = !manager.deselectedEventIDs.contains(event.eventIdentifier)
                                
                                Button {
                                    withAnimation(.spring()) {
                                        if isSelected { manager.deselectedEventIDs.insert(event.eventIdentifier) }
                                        else { manager.deselectedEventIDs.remove(event.eventIdentifier) }
                                    }
                                    UISelectionFeedbackGenerator().selectionChanged()
                                } label: {
                                    HStack(spacing: 16) {
                                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                            .font(.title2)
                                            .foregroundColor(isSelected ? Color(hex: "#818CF8") : .white.opacity(0.2))
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(event.title)
                                                .font(.headline)
                                                .foregroundColor(isSelected ? .white : .white.opacity(0.4))
                                            
                                            Text(event.startDate, style: .date)
                                                .font(.caption.bold())
                                                .foregroundColor(isSelected ? .white.opacity(0.6) : .white.opacity(0.3))
                                        }
                                        Spacer()
                                    }
                                    .padding()
                                    .background(isSelected ? Color.white.opacity(0.05) : Color.black.opacity(0.3))
                                    .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(isSelected ? Color.white.opacity(0.1) : Color.clear, lineWidth: 1))
                                    .cornerRadius(16)
                                    .blur(radius: isSelected ? 0 : 3)
                                    .opacity(isSelected ? 1.0 : 0.4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 120)
                }
            }
            
            // Bottom Import Button
            VStack {
                Spacer()
                Button {
                    importSelectedEvents()
                } label: {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("IMPORT \(manager.selectedEventsCount) EVENTS")
                    }
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        LinearGradient(colors: [Color(hex: "#4F46E5")!, Color(hex: "#7C3AED")!], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .shadow(color: Color(hex: "#7C3AED")!.opacity(0.3), radius: 10, y: 5)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                .disabled(manager.selectedEventsCount == 0)
                .opacity(manager.selectedEventsCount == 0 ? 0.5 : 1.0)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            Task {
                await manager.requestAccess()
                await manager.fetchSmartEvents(context: modelContext)
            }
        }
        .onChange(of: manager.selectedCalendarIDs) { _ in
            Task { await manager.fetchSmartEvents(context: modelContext) }
        }
        .onChange(of: manager.includeHolidays) { _ in
            Task { await manager.fetchSmartEvents(context: modelContext) }
        }
    }
    
    private func importSelectedEvents() {
        let eventsToImport = manager.fetchedEvents.filter { !manager.deselectedEventIDs.contains($0.eventIdentifier) }
        for ekEvent in eventsToImport {
            let randomTheme = Theme.modernPastels.randomElement() ?? Theme.modernPastels[0]
            
            var finalNotes = ""
            if let loc = ekEvent.location, !loc.isEmpty { finalNotes += "📍 Location: \(loc)\n" }
            if let url = ekEvent.url { finalNotes += "🔗 Link: \(url.absoluteString)\n" }
            if !finalNotes.isEmpty { finalNotes += "---\n" }
            if let notes = ekEvent.notes, !notes.isEmpty { finalNotes += notes }
            
            let newEvent = DayEvent(
                title: ekEvent.title,
                targetDate: ekEvent.startDate,
                themeColorHex: randomTheme,
                iconName: "calendar",
                isPremium: true
            )
            newEvent.notes = finalNotes
            newEvent.calendarEventIdentifier = ekEvent.eventIdentifier
            modelContext.insert(newEvent)
        }
        try? modelContext.save()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        WidgetCenter.shared.reloadAllTimelines()
        dismiss()
    }
}

// MARK: - Components
struct ConfigCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 10, weight: .black))
            .foregroundColor(.white.opacity(0.4))
            
            content
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 24).fill(Color.white.opacity(0.05)))
        .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(Color.white.opacity(0.1), lineWidth: 1))
    }
}

struct PremiumToggle: View {
    @Binding var isOn: Bool
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { isOn.toggle() }
            UISelectionFeedbackGenerator().selectionChanged()
        } label: {
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule().fill(isOn ? Color(hex: "#818CF8")! : Color.white.opacity(0.1)).frame(width: 50, height: 28)
                Circle().fill(.white).frame(width: 24, height: 24).padding(2).shadow(radius: 2)
            }
        }
    }
}
