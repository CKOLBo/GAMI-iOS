//
//  MantorFindView.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/19/25.
//

import SwiftUI
import UIKit

struct MentorFindView: View {
    @State private var searchText: String = ""
    
    @State private var mentors: [MentorSummaryDTO] = []
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isApplying: Bool = false
    @State private var showApplyAlert: Bool = false
    @State private var applyAlertMessage: String = ""

    // ✅ 랜덤 검색
    private enum MentorFindTab: String, CaseIterable, Identifiable {
        case list = "멘토찾기"
        case random = "랜덤 검색"
        var id: String { rawValue }
    }

    @State private var selectedTab: MentorFindTab = .list
    @State private var isMatchingPresented: Bool = false
    @State private var isMatchSuccessPresented: Bool = false
    @State private var matchedMentor: MentorSummaryDTO? = nil
    @State private var isMatchFailPresented: Bool = false
    @State private var matchFailMessage: String = ""
    @State private var matchingTask: Task<Void, Never>? = nil
    @State private var isApplyingMentorRequest: Bool = false

    private let service = MentorService()
    private var accessToken: String {
        UserDefaults.standard.string(forKey: "accessToken")?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    private var filteredMentors: [MentorSummaryDTO] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return mentors }

        return mentors.filter { mentor in
            let genText = "\(mentor.generation)기"
            return mentor.name.localizedCaseInsensitiveContains(q)
            || genText.localizedCaseInsensitiveContains(q)
            || mentor.major.localizedCaseInsensitiveContains(q)
        }
    }
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Title tabs (tappable)
                    HStack(alignment: .lastTextBaseline, spacing: 8) {
                        Text("멘토찾기")
                            .font(.custom("Pretendard-Bold", size: 28))
                            .foregroundColor(selectedTab == .list ? Color("Gray1") : Color("Gray3"))
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    selectedTab = .list
                                }
                            }

                        Text("|")
                            .font(.custom("Pretendard-Bold", size: 22))
                            .foregroundColor(Color("Gray3"))
                            .padding(.bottom, 2)

                        Text("랜덤 검색")
                            .font(.custom("Pretendard-Bold", size: 28))
                            .foregroundColor(selectedTab == .random ? Color("Gray1") : Color("Gray3"))
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    selectedTab = .random
                                }
                            }

                        Spacer()
                    }
                    .padding(.top, 24)

                    // Picker removed

                    MentorSearchBarView(searchText: $searchText)
                        .padding(.top, 16)

                    if selectedTab == .random {
                        randomSearchContent
                            .padding(.top, 24)
                    } else {
                        FindBar()
                            .padding(.top, 24)

                        listContent
                    }

                    // Bottom spacer so the last content is tappable above the TabBar
                    Color.clear
                        .frame(height: 110)
                }
                .padding(.horizontal, 31)
            }

            if isMatchingPresented {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()

                matchingModal
                    .transition(.scale)
            }

            if isMatchSuccessPresented {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()

                matchSuccessModal
                    .transition(.scale)
            }

            if isMatchFailPresented {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()

                matchFailModal
                    .transition(.scale)
            }
        }
        .task(id: accessToken) {
            print("✅ MentorFind accessToken =", UserDefaults.standard.string(forKey: "accessToken") ?? "nil")
           
            guard !accessToken.isEmpty else {
                errorMessage = "로그인이 필요합니다. 로그인 후 다시 시도해주세요."
                showError = true
                return
            }
            await fetchMentors()
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 20)
        }
        .frame(maxWidth: .infinity,alignment: .topLeading)
        .navigationBarBackButtonHidden(true)
        .alert("오류", isPresented: $showError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .alert("멘토 신청", isPresented: $showApplyAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(applyAlertMessage)
        }
        
    }
    
    @ViewBuilder
    private var listContent: some View {
        let columns: [GridItem] = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]

        if filteredMentors.isEmpty {
            MentorEmptyView()
                .padding(.top, 40)
        } else {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(filteredMentors) { mentor in
                    MentorCardView(mentor: mentor) {
                        Task {
                            await applyMentor(mentorId: mentor.memberId)
                        }
                    }
                }
            }
            .padding(.top, 18)
        }
    }

    private var randomSearchContent: some View {
        VStack(spacing: 0) {
            // Intro card
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)

                Image("ohing")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 110)
                    .opacity(1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.top, 12)
                    .padding(.trailing, 18)

                (Text("당신에게 맞는\n")
                 + Text("멘토").foregroundColor(Color("Blue1"))
                 + Text("를 추천해드릴게요."))
                    .font(.custom("Pretendard-Bold", size: 16))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
                    .padding(.leading, 16)
                    .padding(.bottom, 16)
                    .padding(.trailing, 140)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 120)

            // Empty state
            VStack(spacing: 0) {
                Image("ohing")
                    .padding(.top, 52)

                Text("당신에게 맞는 멘토를 추천해드릴게요.\n아래 버튼을 눌러 시작해보세요.")
                    .font(.custom("Pretendard-Medium", size: 14))
                    .foregroundColor(Color("Gray2"))
                    .multilineTextAlignment(.center)
                    .padding(.top, 18)

                Button {
                    startRandomMatch()
                } label: {
                    Text("랜덤검색")
                        .font(.custom("Pretendard-Bold", size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("Blue1"))
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, 22)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var matchingModal: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("매칭중...")
                .font(.custom("Pretendard-Bold", size: 16))
                .foregroundColor(Color("Gray1"))
                .padding(.top, 18)

            Text("당신과 잘 맞는 멘토를 찾는 중이에요.\n잠시만 기다려 주세요.")
                .font(.custom("Pretendard-Medium", size: 13))
                .foregroundColor(Color("Gray3"))
                .padding(.top, 10)

            HStack {
                Spacer()
                Button {
                    cancelRandomMatch()
                } label: {
                    Text("취소")
                        .font(.custom("Pretendard-Bold", size: 13))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("Blue1"))
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 18)
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 8)
        )
        .frame(maxWidth: 320)
        .padding(.horizontal, 24)
    }

    private var matchSuccessModal: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("매칭성공!")
                .font(.custom("Pretendard-Bold", size: 16))
                .foregroundColor(Color("Gray1"))
                .padding(.top, 18)

            HStack(spacing: 10) {
                Circle()
                    .fill(Color("Gray4"))
                    .frame(width: 38, height: 38)
                    .overlay(
                        Image(systemName: "ohing")
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(matchedMentor?.name ?? "-")
                        .font(.custom("Pretendard-Bold", size: 14))
                        .foregroundColor(Color("Gray1"))

                    HStack(spacing: 6) {
                        Text("\(matchedMentor?.generation ?? 0)기")
                            .font(.custom("Pretendard-Bold", size: 11))
                            .foregroundColor(Color("Blue1"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(Color("Blue1").opacity(0.12))
                            )

                        Text(matchedMentor?.major ?? "")
                            .font(.custom("Pretendard-Bold", size: 11))
                            .foregroundColor(Color("Gray2"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(Color("Gray4").opacity(0.25))
                            )
                    }
                }

                Spacer()
            }
            .padding(.top, 16)

            HStack(spacing: 10) {
                Button {
                    // 다시 돌리기
                    isMatchSuccessPresented = false
                    startRandomMatch()
                } label: {
                    Text("다시 돌리기")
                        .font(.custom("Pretendard-Bold", size: 13))
                        .foregroundColor(Color("Gray1"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("Gray4").opacity(0.25))
                        )
                }
                .buttonStyle(.plain)

                Button {
                    guard let mentorId = matchedMentor?.memberId else { return }
                    guard !isApplyingMentorRequest else { return }

                    isApplyingMentorRequest = true
                    print("➡️ POST /api/mentoring/apply/\(mentorId)")

                    Task {
                        let success = await applyMentorForSuccessModal(mentorId: mentorId)
                        await MainActor.run {
                            isApplyingMentorRequest = false
                            if success {
                                isMatchSuccessPresented = false
                            }
                        }
                    }
                } label: {
                    Text(isApplyingMentorRequest ? "신청 중..." : "멘토신청")
                        .font(.custom("Pretendard-Bold", size: 13))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("Blue1"))
                        )
                }
                .buttonStyle(.plain)
                .disabled(isApplyingMentorRequest)
                .opacity(isApplyingMentorRequest ? 0.6 : 1)
            }
            .padding(.top, 18)
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 8)
        )
        .frame(maxWidth: 340)
        .padding(.horizontal, 24)
    }

    private func isHTTP404(_ error: Error) -> Bool {
        let desc = error.localizedDescription
        if desc.contains("HTTP 404") || desc.contains("(HTTP 404)") { return true }
        let debug = String(describing: error)
        return debug.contains("404")
    }

    private func isHTTP409(_ error: Error) -> Bool {
        let desc = error.localizedDescription
        if desc.contains("HTTP 409") || desc.contains("(HTTP 409)") { return true }
        let debug = String(describing: error)
        return debug.contains("409")
    }
    @MainActor
    private func applyMentorForSuccessModal(mentorId: Int) async -> Bool {
        // Reuse the same alert messaging, but return whether it succeeded.
        guard !isApplying else { return false }
        isApplying = true
        defer { isApplying = false }

        do {
            _ = try await service.applyMentor(mentorId: mentorId)
            applyAlertMessage = "멘토 신청이 완료되었어요."
            showApplyAlert = true
            return true
        } catch {
            // ✅ 이미 신청한 멘토(409)면 사용자에게 친절하게 안내하고 모달은 닫아도 됨
            if isHTTP409(error) {
                applyAlertMessage = "이미 신청한 멘토예요.\n채팅 > 요청에서 확인해보세요."
                showApplyAlert = true
                return true
            }

            applyAlertMessage = error.localizedDescription
            showApplyAlert = true
            return false
        }
    }

    private var matchFailModal: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("매칭 실패")
                .font(.custom("Pretendard-Bold", size: 16))
                .foregroundColor(Color("Gray1"))
                .padding(.top, 18)

            Text(matchFailMessage)
                .font(.custom("Pretendard-Medium", size: 13))
                .foregroundColor(Color("Gray3"))
                .padding(.top, 10)

            HStack(spacing: 10) {
                Button {
                    isMatchFailPresented = false
                } label: {
                    Text("닫기")
                        .font(.custom("Pretendard-Bold", size: 13))
                        .foregroundColor(Color("Gray1"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("Gray4").opacity(0.25))
                        )
                }
                .buttonStyle(.plain)

                Button {
                    isMatchFailPresented = false
                    startRandomMatch()
                } label: {
                    Text("다시 돌리기")
                        .font(.custom("Pretendard-Bold", size: 13))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("Blue1"))
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 18)
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 8)
        )
        .frame(maxWidth: 340)
        .padding(.horizontal, 24)
    }

    private func startRandomMatch() {
        guard !isMatchingPresented else { return }

        // mentors가 아직 없으면 먼저 로딩
        if mentors.isEmpty {
            Task { await fetchMentors() }
        }

        matchedMentor = nil
        isMatchSuccessPresented = false
        isMatchFailPresented = false
        isMatchingPresented = true

        matchingTask?.cancel()
        matchingTask = Task {
            // UX 딜레이
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            guard !Task.isCancelled else { return }

            do {
                let picked = try await service.fetchRandomMentor()
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    isMatchingPresented = false
                    matchedMentor = picked
                    isMatchSuccessPresented = true
                }
            } catch {
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    isMatchingPresented = false

                    if isHTTP404(error) {
                        // ✅ 조건에 맞는 멘토 없음 (정상 케이스로 처리)
                        matchFailMessage = "조건에 맞는 멘토를 찾지 못했어요.\n다시 돌려볼까요?"
                        isMatchFailPresented = true
                    } else {
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            }
        }
    }

    private func cancelRandomMatch() {
        matchingTask?.cancel()
        matchingTask = nil
        isMatchingPresented = false
    }
    
    func FindBar() -> some View{
        ZStack(alignment: .bottomLeading) {
            // Background card
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)

            // Decorative image (keeps aspect ratio; never pushes layout)
            Image("ohing")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 120)
                .opacity(1)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(.top, 12)
                .padding(.trailing, 18)

            // Text
            (Text("당신에게 맞는\n")
             + Text("멘토").foregroundColor(Color("Blue1"))
             + Text("를 못 찾겠다면?"))
                .font(.custom("Pretendard-Bold", size: 16))
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .minimumScaleFactor(0.9)
                .padding(.leading, 16)
                .padding(.bottom, 16)
                .padding(.trailing, 140) // reserve space for the image on the right
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 120)
    }
    
    @MainActor
    private func fetchMentors() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            mentors = try await service.fetchMentorsAll(page: 0, size: 50)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    @MainActor
    private func applyMentor(mentorId: Int) async {
        guard !isApplying else { return }
        isApplying = true
        defer { isApplying = false }

        do {
            _ = try await service.applyMentor(mentorId: mentorId)
            applyAlertMessage = "멘토 신청이 완료되었어요."
            showApplyAlert = true
        } catch {
            applyAlertMessage = error.localizedDescription
            showApplyAlert = true
        }
    }
}

#Preview {
    MentorFindView()
        .onAppear {
          
            UserDefaults.standard.set("preview_dummy_token", forKey: "accessToken")
        }
}
