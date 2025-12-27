//
//  MantorFindView.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/19/25.
//

import SwiftUI

struct MentorFindView: View {
    @State private var searchText: String = ""
    
    @State private var mentors: [MentorSummaryDTO] = []
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isApplying: Bool = false
    @State private var showApplyAlert: Bool = false
    @State private var applyAlertMessage: String = ""

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
        ScrollView{
            VStack(alignment: .leading ,spacing: 0){
                Text("멘토찾기")
                    .font(.custom("Pretendard-Bold", size: 32))
                    .padding(.top, 60)
                MentorSearchBarView(searchText: $searchText)
                    .padding(.top, 50)
                
            } .padding(.horizontal, 32)

            
            FindBar()
                .padding(.top,24)
                .padding(.horizontal, 31)
            
            let columns: [GridItem] = [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ]
            
            if filteredMentors.isEmpty {
                MentorEmptyView()
                    .padding(.horizontal, 31)
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
                .padding(.horizontal, 31)
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
        .frame(maxWidth: .infinity,alignment: .topLeading)
        .ignoresSafeArea()
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
    
    func FindBar() -> some View{
        ZStack(){
            
            Image("ohing")
            
                .padding(.bottom, 52)
                .padding(.top, 8)
                .padding(.horizontal, 144)
                .background(Color.white)
               
                .cornerRadius(12)
                .shadow(
                    color: .black.opacity(0.1),
                    radius: 12,
                    x: 0, y: 6
                )
            
            VStack(alignment: .leading){
                Text("당신에게 맞는 \n")
                +
                Text("멘토")
                    .foregroundColor(Color("Blue1"))
                +
                Text("를 못 찾겠다면?")
            }
            .font(.custom("Pretendard-Bold", size: 16))
            .padding(.top, 66)
            .padding(.bottom, 16)
            .padding(.leading, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            
 


        }
        
        
    }
    
    @MainActor
    private func fetchMentors() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            mentors = try await service.fetchMentorsAll(page: 0, size: 10)
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
