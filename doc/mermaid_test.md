# Mermaid 类图测试

测试修复后的系统类图是否可以正常渲染：

```mermaid
classDiagram
    %% 用户相关类
    class User {
        -Long userId
        -String username
        -String email
        -String password
        -String nickname
        -String avatar
        -UserRole role
        -UserStatus status
        -Date createTime
        -Date updateTime
        +login(String email, String password) Boolean
        +register(UserRegisterDto dto) Boolean
        +updateProfile(UserProfileDto dto) Boolean
        +resetPassword(String email, String newPassword) Boolean
    }
    
    class Author {
        -String penName
        -String bio
        -String contact
        -AuthorStatus status
        -Date applyTime
        -Date approveTime
        +createBook(BookCreateDto dto) Book
        +publishChapter(ChapterDto dto) Chapter
        +getBookStats(Long bookId) BookStats
    }
    
    class Admin {
        -AdminRole adminRole
        -String permissions
        +reviewBook(Long bookId, ReviewDto dto) Boolean
        +reviewAuthorApply(Long userId, Boolean approve) Boolean
        +manageUser(Long userId, UserManageDto dto) Boolean
    }
    
    %% 书籍相关类
    class Book {
        -Long bookId
        -String title
        -String description
        -String coverUrl
        -Long authorId
        -BookStatus status
        -BookCategory category
        -Integer chapterCount
        -Integer viewCount
        -Integer likeCount
        -Date createTime
        -Date updateTime
        +addChapter(Chapter chapter) Boolean
        +updateStatus(BookStatus status) Boolean
        +getChapterList() List~Chapter~
    }
    
    class Chapter {
        -Long chapterId
        -Long bookId
        -String title
        -String content
        -Integer chapterOrder
        -ChapterStatus status
        -Integer wordCount
        -Date createTime
        -Date publishTime
        +updateContent(String content) Boolean
        +publish() Boolean
        +getWordCount() Integer
    }
    
    class Category {
        -Long categoryId
        -String categoryName
        -String description
        -Integer bookCount
        +addBook(Book book) Boolean
        +getBookList() List~Book~
    }
    
    %% 互动相关类
    class Comment {
        -Long commentId
        -Long bookId
        -Long userId
        -String content
        -Integer rating
        -CommentStatus status
        -Date createTime
        +reply(String content) Comment
        +like() Boolean
        +report() Boolean
    }
    
    class Like {
        -Long likeId
        -Long userId
        -Long bookId
        -LikeType type
        -Date createTime
        +toggle() Boolean
    }
    
    class Follow {
        -Long followId
        -Long followerId
        -Long authorId
        -Date createTime
        +unfollow() Boolean
    }
    
    %% 系统功能类
    class Notification {
        -Long notificationId
        -Long userId
        -String title
        -String content
        -NotificationType type
        -Boolean isRead
        -Date createTime
        +markAsRead() Boolean
        +delete() Boolean
    }
    
    class Review {
        -Long reviewId
        -Long targetId
        -ReviewType type
        -ReviewStatus status
        -String reviewComment
        -Long reviewerId
        -Date createTime
        -Date reviewTime
        +approve(String comment) Boolean
        +reject(String reason) Boolean
    }
    
    class AIService {
        -String apiKey
        -String baseUrl
        +correctText(String text) String
        +continueContent(String context) String
        +suggestPlot(String outline) String
    }
    
    %% 类之间的关系
    User <|-- Author
    User <|-- Admin
    
    Author ||--o{ Book
    Book ||--o{ Chapter
    Book }o--|| Category
    
    User ||--o{ Comment
    User ||--o{ Like
    User ||--o{ Follow
    User ||--o{ Notification
    
    Book ||--o{ Comment
    Book ||--o{ Like
    Book ||--o{ Review
    Chapter ||--o{ Review
    
    Admin ||--o{ Review
    Author ||--o{ AIService
```

## 关系说明

- `User <|-- Author`: User类被Author类继承
- `User <|-- Admin`: User类被Admin类继承
- `Author ||--o{ Book`: Author与Book是一对多关系
- `Book ||--o{ Chapter`: Book与Chapter是一对多关系
- `Book }o--|| Category`: Book与Category是多对一关系
- 其他关系类似，表示各实体间的关联关系

修复说明：移除了所有中文关系标签，使用标准的Mermaid语法。