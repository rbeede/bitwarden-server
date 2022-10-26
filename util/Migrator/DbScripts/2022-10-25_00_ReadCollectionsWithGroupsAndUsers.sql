-- Stored Procedure: CollectionGroup_ReadByCollectionId
CREATE OR ALTER PROCEDURE [dbo].[CollectionGroup_ReadByCollectionId]
    @CollectionId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON

    SELECT
        [GroupId] [Id],
        [ReadOnly],
        [HidePasswords]
    FROM
        [dbo].[CollectionGroup]
    WHERE
        [CollectionId] = @CollectionId
END
GO

-- Stored Procedure: Collection_ReadWithGroupsAndUsersById
CREATE OR ALTER PROCEDURE [dbo].[Collection_ReadWithGroupsAndUsersById]
    @Id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON

    EXEC [dbo].[Collection_ReadById] @Id

    EXEC [dbo].[CollectionGroup_ReadByCollectionId] @Id

    EXEC [dbo].[CollectionUser_ReadByCollectionId] @Id
END
GO

-- Stored Procedure: Collection_ReadWithGroupsAndUsersByIdUserId
CREATE OR ALTER PROCEDURE [dbo].[Collection_ReadWithGroupsAndUsersByIdUserId]
    @Id UNIQUEIDENTIFIER,
    @UserId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON

    EXEC [dbo].[Collection_ReadByIdUserId] @Id, @UserId

    EXEC [dbo].[CollectionGroup_ReadByCollectionId] @Id

    EXEC [dbo].[CollectionUser_ReadByCollectionId] @Id
END
GO

-- Stored Procedure: Collection_CreateWithGroupsAndUsers
CREATE OR ALTER PROCEDURE [dbo].[Collection_CreateWithGroupsAndUsers]
    @Id UNIQUEIDENTIFIER,
    @OrganizationId UNIQUEIDENTIFIER,
    @Name VARCHAR(MAX),
    @ExternalId NVARCHAR(300),
    @CreationDate DATETIME2(7),
    @RevisionDate DATETIME2(7),
    @Groups AS [dbo].[SelectionReadOnlyArray] READONLY,
    @Users AS [dbo].[SelectionReadOnlyArray] READONLY
AS
BEGIN
    SET NOCOUNT ON

    EXEC [dbo].[Collection_Create] @Id, @OrganizationId, @Name, @ExternalId, @CreationDate, @RevisionDate

    -- Groups
    ;WITH [AvailableGroupsCTE] AS(
        SELECT
            [Id]
        FROM
            [dbo].[Group]
        WHERE
            [OrganizationId] = @OrganizationId
    )
    INSERT INTO [dbo].[CollectionGroup]
    (
        [CollectionId],
        [GroupId],
        [ReadOnly],
        [HidePasswords]
    )
    SELECT
        @Id,
        [Id],
        [ReadOnly],
        [HidePasswords]
    FROM
        @Groups
    WHERE
        [Id] IN (SELECT [Id] FROM [AvailableGroupsCTE])

    -- Users
    ;WITH [AvailableUsersCTE] AS(
        SELECT
            [Id]
        FROM
            [dbo].[OrganizationUser]
        WHERE
            [OrganizationId] = @OrganizationId
    )
    INSERT INTO [dbo].[CollectionUser]
    (
        [CollectionId],
        [OrganizationUserId],
        [ReadOnly],
        [HidePasswords]
    )
    SELECT
        @Id,
        [Id],
        [ReadOnly],
        [HidePasswords]
    FROM
        @Users
    WHERE
        [Id] IN (SELECT [Id] FROM [AvailableUsersCTE])

    EXEC [dbo].[User_BumpAccountRevisionDateByOrganizationId] @OrganizationId
END