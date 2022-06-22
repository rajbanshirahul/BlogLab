USE BlogDB;
GO


CREATE OR ALTER PROCEDURE [dbo].[Account_GetByUsername]
	@NormalizedUsername VARCHAR(20)
AS
BEGIN
	SELECT
		[ApplicationUserId]
		,[Username]
		,[NormalizedUsername]
		,[Email]
		,[NormalizedEmail]
		,[Fullname]
		,[PasswordHash]
	FROM
		[dbo].[ApplicationUser] t1
	WHERE
		t1.[NormalizedUsername] = @NormalizedUsername;
END
GO


CREATE OR ALTER PROCEDURE [dbo].[Account_Insert]
	@Account AccountType READONLY
AS
BEGIN
	INSERT INTO [dbo].[ApplicationUser]
			([Username],
			[NormalizedUsername],
			[Email],
			[NormalizedEmail],
			[Fullname],
			[PasswordHash])
		 SELECT 
			[Username],
			[NormalizedUsername],
			[Email],
			[NormalizedEmail],
			[Fullname],
			[PasswordHash]
		 FROM
			@Account;
		
		SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO


CREATE OR ALTER PROCEDURE [dbo].[Blog_Delete]
	@BlogId INT
AS
BEGIN
	
	UPDATE [dbo].[BlogComment]
	SET [ActiveInd] = CONVERT(BIT, 0)
	WHERE [BlogId] = @BlogId;

	UPDATE [dbo].[Blog]
	SET
		[PhotoId] = NULL,
		[ActiveInd] = CONVERT(BIT, 0)
	WHERE
		[BlogId] = @BlogId
END
GO


CREATE OR ALTER PROCEDURE [dbo].[Blog_Get]
	@BlogId INT
AS
BEGIN
	SELECT
		[BlogId],
		[ApplicationUserId],
		[Username],
		[Title],
		[Content],
		[PhotoId],
		[PublishDate],
		[UpdateDate]
	FROM
		[aggregate].[Blog] t1
	WHERE
		t1.[BlogId] = @BlogId AND
		t1.[ActiveInd] = CONVERT(BIT, 1);
END
GO


CREATE OR ALTER PROCEDURE [dbo].[Blog_GetAll]
	@Offset INT,
	@PageSize INT
AS
BEGIN
	SELECT
		[BlogId],
		[ApplicationUserId],
		[Username],
		[Title],
		[Content],
		[PhotoId],
		[PublishDate],
		[UpdateDate]
	FROM
		[aggregate].[Blog] t1
	WHERE
		t1.[ActiveInd] = CONVERT(BIT, 1)
	ORDER BY
		t1.[BlogId]
	OFFSET @Offset ROWS
	FETCH NEXT @PageSize ROWS ONLY;

	SELECT COUNT(*) FROM [aggregate].[Blog] t1 WHERE t1.[ActiveInd] = CONVERT(BIT, 1);
END
GO


CREATE OR ALTER PROCEDURE [dbo].[Blog_GetAllFamous]
AS
BEGIN
	SELECT TOP 6
		t1.[BlogId],
		t1.[ApplicationUserId],
		t1.[Username],
		t1.[PhotoId],
		t1.[Title],
		t1.[Content],
		t1.[PublishDate],
		t1.[UpdateDate]
	FROM
		[aggregate].[Blog] t1
	INNER JOIN
		[dbo].[BlogComment] t2 ON t1.[BlogId] = t2.[BlogId]
	WHERE
		t1.[ActiveInd] = CONVERT(BIT, 1) AND
		t1.[ActiveInd] = CONVERT(BIT, 1)
	GROUP BY
		t1.[BlogId],
		t1.[ApplicationUserId],
		t1.[Username],
		t1.[PhotoId],
		t1.[Title],
		t1.[Content],
		t1.[PublishDate],
		t1.[UpdateDate],
		t1.[ActiveInd]
	ORDER BY
		COUNT(t2.[BlogCommentId])
	DESC;
END
GO


CREATE OR ALTER PROCEDURE [dbo].[Blog_GetByUserId]
	@ApplicationUserId INT
AS
BEGIN
	SELECT
		t1.[BlogId],
		t1.[ApplicationUserId],
		t1.[Username],
		t1.[Title],
		t1.[Content],
		t1.[PhotoId],
		t1.[PublishDate],
		t1.[UpdateDate]
	FROM
		[aggregate].[Blog] t1
	WHERE
		t1.[ApplicationUserId] = @ApplicationUserId AND
		t1.[ActiveInd] = CONVERT(BIT, 1);
END
GO


CREATE OR ALTER PROCEDURE [dbo].[Blog_Upsert]
	@Blog BlogType READONLY,
	@ApplicationUserId INT
AS
BEGIN
	
	MERGE INTO [dbo].[Blog] TARGET
	USING (
		SELECT
			BlogId,
			@ApplicationUserId [ApplicationUserId],
			Title,
			Content,
			PhotoId
		FROM
			@Blog
	) AS SOURCE
	ON
	(
		TARGET.BlogId = SOURCE.BlogId AND TARGET.ApplicationUserId = SOURCE.ApplicationUserId
	)
	WHEN MATCHED THEN
		UPDATE SET
			TARGET.[Title] = SOURCE.[Title],
			TARGET.[Content] = SOURCE.[Content],
			TARGET.[PhotoId] = SOURCE.[PhotoId],
			TARGET.[UpdateDate] = GETDATE()
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			[ApplicationUserId],
			[Title],
			[Content],
			[PhotoId]
		)
		VALUES (
			SOURCE.[ApplicationUserId],
			SOURCE.[Title],
			SOURCE.[Content],
			SOURCE.[PhotoId]
		);

	SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO


---- TIP: RECURSIVE CTE USED HERE
CREATE OR ALTER PROCEDURE [dbo].[BlogComment_Delete]
	@BlogCommentId INT
AS
BEGIN
	DROP TABLE IF EXISTS #BlogCommentsToBeDeleted;

	WITH cte_blogComments AS (
		SELECT
			t1.[BlogCommentId],
			t1.[ParentBlogCommentId]
		FROM
			[dbo].[BlogComment] t1
		WHERE
			t1.[BlogCommentId] = @BlogCommentId
		UNION ALL
		SELECT
			t2.[BlogCommentId],
			t2.[ParentBlogCommentId]
		FROM
			[dbo].[BlogComment] t2
			INNER JOIN cte_blogComments t3
				ON t3.[BlogCommentId] = t2.[ParentBlogCommentId]
	)

	SELECT
		[BlogCommentId],
		[ParentBlogCommentId]
	INTO
		#BlogCommentsToBeDeleted
	FROM
		cte_blogComments;

	UPDATE t1
	SET
		t1.[ActiveInd] = CONVERT(BIT, 0),
		t1.[UpdateDate] = GETDATE()
	FROM
		[dbo].[BlogComments] t1
		INNER JOIN #BlogCommentsToBeDeleted t2
			ON t1.[BlogCommentId] = t2.[BlogCommentId];
END
GO


CREATE OR ALTER PROCEDURE [dbo].[BlogComment_Get]
	@BlogCommentId INT
AS
BEGIN
	SELECT
		t1.[BlogCommentId],
		t1.[ParentBlogCommentId],
		t1.[BlogId],
		t1.[ApplicationUserId],
		t1.[Username],
		t1.[Content],
		t1.[PublishDate],
		t1.[UpdateDate]
	FROM
		[aggregate].[BlogComment] t1
	WHERE
		t1.[BlogCommentId] = @BlogCommentId AND
		t1.[ActiveInd] = CONVERT(BIT, 1)
END
GO


CREATE OR ALTER PROCEDURE [dbo].[BlogComment_GetAll]
	@BlogId INT
AS
BEGIN
	SELECT
		t1.[BlogCommentId],
		t1.[ParentBlogCommentId],
		t1.[BlogId],
		t1.[ApplicationUserId],
		t1.[Username],
		t1.[Content],
		t1.[PublishDate],
		t1.[UpdateDate]
	FROM
		[aggregate].[BlogComment] t1
	WHERE
		t1.[BlogId] = @BlogId AND
		t1.[ActiveInd] = CONVERT(BIT, 1)
	ORDER BY
		t1.[UpdateDate]
	DESC;
END
GO


CREATE OR ALTER PROCEDURE [dbo].[BlogComment_Upsert]
	@BlogComment BlogCommentType READONLY,
	@ApplicationUserId INT
AS
BEGIN
	
	MERGE INTO [dbo].[BlogComment] TARGET
	USING (
		SELECT
			[BlogCommentId],
			[ParentBlogCommentId],
			[BlogId],
			[Content],
			@ApplicationUserId [ApplicationUserId]
		FROM
			@BlogComment
	) AS SOURCE
	ON
	(
		TARGET.[BlogCommentId] = SOURCE.[BlogCommentId] AND
		TARGET.[ApplicationUserId] = SOURCE.[ApplicationUserId]
	)
	WHEN MATCHED THEN
		UPDATE SET
			TARGET.[Content] = SOURCE.[Content],
			TARGET.[UpdateDate] = GETDATE()
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			[ParentBlogCommentId],
			[BlogId],
			[ApplicationUserId],
			[Content]
		)
		VALUES
		(
			SOURCE.[ParentBlogCommentId],
			SOURCE.[BlogId],
			SOURCE.[ApplicationUserId],
			SOURCE.[Content]
		);

	SELECT CAST(SCOPE_IDENTITY() AS INT)
END
GO


CREATE OR ALTER PROCEDURE [dbo].[Photo_Delete]
	@PhotoId INT
AS
BEGIN
	DELETE FROM [dbo].[Photo] WHERE [PhotoId] = @PhotoId
END
GO


CREATE OR ALTER PROCEDURE [dbo].[Photo_Get]
	@PhotoId INT
AS
BEGIN
	SELECT
		t1.[PhotoId],
		t1.[ApplicationUserId],
		t1.[PublicId],
		t1.[ImageUrl],
		t1.[Description],
		t1.[PublishedDate],
		t1.[UpdateDate]
	FROM
		[dbo].[Photo] t1
	WHERE
		t1.[PhotoId] = @PhotoId;
END
GO

CREATE PROCEDURE [dbo].[Photo_GetByUserId]
	@ApplicationUserId INT
AS
BEGIN
	SELECT
		t1.[PhotoId],
		t1.[ApplicationUserId],
		t1.[PublicId],
		t1.[ImageUrl],
		t1.[Description],
		t1.[PublishedDate],
		t1.[UpdateDate]
	FROM
		[dbo].[Photo] t1
	WHERE
		t1.[ApplicationUserId] = @ApplicationUserId;
END
GO


CREATE OR ALTER PROCEDURE [dbo].[Photo_Insert]
	@Photo PhotoType READONLY,
	@ApplicationUserId INT
AS
BEGIN
	INSERT INTO [dbo].[Photo]
			   ([ApplicationUserId]
			   ,[PublicId]
			   ,[ImageUrl]
			   ,[Description])
	SELECT
		@ApplicationUserId,
		[PublicId],
		[ImageUrl],
		[Description]
	FROM
		@Photo;

	SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO

