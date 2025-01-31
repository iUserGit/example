import Foundation

public typealias UnsplashDM = DomainModel.UnsplashModel

public enum DomainModel {
    public enum UnsplashModel {
        
        // MARK: - UnsplashPhoto
        public struct Photo: Codable {
            public let id: String
            public let slug: String?
            public let alternativeSlugs: [String: String]?
            public let createdAt: Date
            public let updatedAt: Date?
            public let promotedAt: Date?
            public let width: Int?
            public let height: Int?
            public let color: String?
            public let blurHash: String?
            public let description: String?
            public let altDescription: String?
            public let urls: PhotoURLs?
            public let links: PhotoLinks?
            public let likes: Int?
            public let likedByUser: Bool?
            public let sponsorship: Sponsorship?
            public let topicSubmissions: [String: TopicSubmission]?
            public let assetType: String?
            public let user: User?

             enum CodingKeys: String, CodingKey {
                case id, slug, width, height, color, description, urls, links, likes, sponsorship, user
                case alternativeSlugs = "alternative_slugs"
                case createdAt = "created_at"
                case updatedAt = "updated_at"
                case promotedAt = "promoted_at"
                case blurHash = "blur_hash"
                case altDescription = "alt_description"
                case likedByUser = "liked_by_user"
                case topicSubmissions = "topic_submissions"
                case assetType = "asset_type"
            }
        }

        // MARK: - PhotoURLs
        public struct PhotoURLs: Codable {
            public let raw, full, regular, small, thumb: String?
        }

        // MARK: - PhotoLinks
        public struct PhotoLinks: Codable {
            public let html, download, downloadLocation: String?

            enum CodingKeys: String, CodingKey {
                case html, download
                case downloadLocation = "download_location"
            }
        }

        // MARK: - Sponsorship
        public struct Sponsorship: Codable {
            public let sponsor: User?
        }

        // MARK: - TopicSubmission
        public struct TopicSubmission: Codable {
            public let status: String?
            public let approvedOn: String?

            enum CodingKeys: String, CodingKey {
                case status
                case approvedOn = "approved_on"
            }
        }

        // MARK: - User
        public struct User: Codable {
            public let id: String
            public let lastName: String?
            public let username: String?
            public let name: String?
            public let firstName: String?
            public let portfolioURL: String?
            public let location: String?
            public let profileImage: ProfileImage?
            public let totalPhotos: Int?
            public let forHire: Bool?
            public let social: SocialLinks?

            enum CodingKeys: String, CodingKey {
                case id, username, name, location
                case firstName = "first_name"
                case lastName = "last_name"
                case portfolioURL = "portfolio_url"
                case profileImage = "profile_image"
                case totalPhotos = "total_photos"
                case forHire = "for_hire"
                case social
            }
        }

        // MARK: - ProfileImage
        public struct ProfileImage: Codable {
            let small, medium, large: String?
        }

        // MARK: - SocialLinks
        public struct SocialLinks: Codable {
            public let instagramUsername: String?
            public let portfolioURL: String?
            public let twitterUsername: String?

            enum CodingKeys: String, CodingKey {
                case instagramUsername = "instagram_username"
                case portfolioURL = "portfolio_url"
                case twitterUsername = "twitter_username"
            }
        }
    }
}
