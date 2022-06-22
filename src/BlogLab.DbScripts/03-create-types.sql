USE BlogDB;
GO


CREATE TYPE [dbo].[AccountType] AS TABLE
(
	[Username] VARCHAR(20) NOT NULL,
	[NormalizedUsername] VARCHAR(20) NOT NULL,
	[Email] VARCHAR(30) NOT NULL,
	[NormalizedEmail] VARCHAR(30) NOT NULL,
	[Fullname] VARCHAR(30) NULL,
	[PasswordHash] NVARCHAR(MAX) NOT NULL
);
GO


CREATE TYPE [dbo].[PhotoType] AS TABLE
(
	[PublicId] VARCHAR(50) NOT NULL,
	[ImageUrl] VARCHAR(250) NOT NULL,
	[Description] VARCHAR(30) NOT NULL
);
GO


CREATE TYPE [dbo].[BlogType] AS TABLE
(
	[BlogId] INT NOT NULL,
	[Title] VARCHAR(50) NOT NULL,
	[Content] VARCHAR(MAX) NOT NULL,
	[PhotoId] INT NULL
);
GO


CREATE TYPE [dbo].[BlogCommentType] AS TABLE
(
	[BlogCommentId] INT NOT NULL,
	[ParentBlogCommentId] INT NULL,
	[BlogId] INT NOT NULL,
	[Content] VARCHAR(300) NOT NULL
);
GO

