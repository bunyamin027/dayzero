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
        HStack {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { task.isCompleted.toggle() }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? Color(hex: "#10B981")! : .secondary)
            }
            Text(task.title)
                .strikethrough(task.isCompleted)
                .foregroundColor(task.isCompleted ? .secondary : .primary)
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(task.isCompleted ? Color(hex: "#10B981")!.opacity(0.3) : themeColor.opacity(0.4), lineWidth: 1.5)
        )
        .opacity(task.isCompleted ? 0.6 : 1.0)
        .shadow(color: themeColor.opacity(0.15), radius: 6, x: 0, y: 3)
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
                                    .foregroundColor(Color(hex: "#818CF8")!)
                                TextField("Add a milestone...", text: $newTaskTitle)
                                    .focused($taskInputFocused)
                                    .onSubmit { addMilestone() }
                                Button { addMilestone() } label: {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(newTaskTitle.isEmpty ? .secondary : Color(hex: "#818CF8")!)
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
                            .shadow(color: Color(hex: selectedThemeHex)!.opacity(0.15), radius: 12, x: 0, y: 6)
                            .padding(.horizontal, 16)
                            
                            // Tasks List
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
                            }
                        }
                        .padding(.top, 20)

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
        guard storeKitManager.isPro else { showingPaywall = true; return }
        if let event = eventToEdit {
            let task = EventTask(title: newTaskTitle)
            task.event = event
            modelContext.insert(task)
            newTaskTitle = ""
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
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
