CREATE PROCEDURE [dbo].[Notification_ReadByUserIdAndStatus]
    @UserId UNIQUEIDENTIFIER,
    @ClientType TINYINT,
    @Read BIT,
    @Deleted BIT
AS
BEGIN
    SET NOCOUNT ON

    SELECT n.*
    FROM [dbo].[NotificationView] n
             LEFT JOIN [dbo].[OrganizationUserView] ou ON n.[OrganizationId] = ou.[OrganizationId]
        AND ou.[UserId] = @UserId
             LEFT JOIN [dbo].[NotificationStatusView] ns ON n.[Id] = ns.[NotificationId]
        AND ns.[UserId] = @UserId
    WHERE [ClientType] IN (0, CASE WHEN @ClientType != 0 THEN @ClientType END)
      AND ([Global] = 1
        OR (n.[UserId] = @UserId
            AND (n.[OrganizationId] IS NULL
                OR ou.[OrganizationId] IS NOT NULL))
        OR (n.[UserId] IS NULL
            AND ou.[OrganizationId] IS NOT NULL))
      AND ((@Read IS NULL AND @Deleted IS NULL)
        OR (ns.[NotificationId] IS NOT NULL
            AND ((@Read IS NULL
                OR IIF((@Read = 1 AND ns.[ReadDate] IS NOT NULL) OR
                       (@Read = 0 AND ns.[ReadDate] IS NULL),
                       1, 0) = 1)
                OR (@Deleted IS NULL
                    OR IIF((@Deleted = 1 AND ns.[DeletedDate] IS NOT NULL) OR
                           (@Deleted = 0 AND ns.[DeletedDate] IS NULL),
                           1, 0) = 1))))
    ORDER BY [Priority] DESC, n.[CreationDate] DESC
END
