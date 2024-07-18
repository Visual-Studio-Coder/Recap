//import SwiftUI
//import LinkPresentation
//import UniformTypeIdentifiers
//
//final class PreviewViewModel: ObservableObject {
//    
//    @Published var image: UIImage?
//    @Published var title: String?
//    @Published var url: String?
//    
//    let previewURL: URL?
//    
//    init(_ url: String) {
//            self.previewURL = URL(string: url)
//            
//            fetchMetadata()
//        }
//    private func fetchMetadata() {
//        guard let previewURL else { return }
//        let provider = LPMetadataProvider()
//        
//        Task {
//            let metadata = try await provider.startFetchingMetadata(for: previewURL)
//            
//            image = try await convertToImage(metadata.imageProvider)
//            title = metadata.title
//            
//            url = metadata.url?.host()
//        }
//    }
//    private func convertToImage(_ imageProvider: NSItemProvider?) async throws -> UIImage? {
//        var image: UIImage?
//        
//        if let imageProvider {
//            let type = String(describing: UTType.image)
//            
//            if imageProvider.hasItemConformingToTypeIdentifier(type) {
//                let item = try await imageProvider.loadItem(forTypeIdentifier: type)
//                
//                if item is UIImage {
//                    image = item as? UIImage
//                }
//                
//                if item is URL {
//                    guard let url = item as? URL,
//                          let data = try? Data(contentsOf: url) else { return nil }
//                    
//                    image = UIImage(data: data)
//                }
//                
//                if item is Data {
//                    guard let data = item as? Data else { return nil }
//                    
//                    image = UIImage(data: data)
//                }
//            }
//        }
//        
//        return image
//    }
//}
//
//struct FileLinkView: View {
//    
//    @ObservedObject var viewModel: PreviewViewModel
//    
//    var body: some View {
//        HStack(spacing: 15) {
//            if let image = viewModel.image {
//                Image(uiImage: image)
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(maxWidth: 107, maxHeight: 107)
//                    .clipped()
//                    .cornerRadius(16)
//            }
//            
//            VStack(alignment: .leading, spacing: 1, content: {
//                if let title = viewModel.title {
//                    Text(title)
//                        .font(.body)
//                        .foregroundColor(.black)
//                        .multilineTextAlignment(.leading)
//                }
//                
//                if let url = viewModel.url {
//                    Text(url)
//                        .font(.footnote)
//                        .foregroundColor(.gray)
//                        .multilineTextAlignment(.leading)
//                }
//            })
//            .padding(.top, 16)
//            .padding(.bottom, 9)
//            .padding(.trailing, 40)
//        }
//        .frame(maxWidth: .infinity, maxHeight: 100)
//    }
//}
