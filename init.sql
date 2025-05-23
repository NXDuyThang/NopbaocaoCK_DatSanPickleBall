IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
GO

CREATE TABLE [Courts] (
    [CourtID] int NOT NULL IDENTITY,
    [Name] nvarchar(100) NOT NULL,
    [CourtType] nvarchar(20) NOT NULL,
    [Location] nvarchar(200) NOT NULL,
    [HourlyRate] decimal(18,2) NOT NULL,
    [Description] nvarchar(1000) NULL,
    [Status] bit NOT NULL,
    [CreatedAt] datetime2 NOT NULL DEFAULT (GETDATE()),
    CONSTRAINT [PK_Courts] PRIMARY KEY ([CourtID])
);
GO

CREATE TABLE [Roles] (
    [Id] nvarchar(450) NOT NULL,
    [Name] nvarchar(256) NULL,
    [NormalizedName] nvarchar(256) NULL,
    [ConcurrencyStamp] nvarchar(max) NULL,
    CONSTRAINT [PK_Roles] PRIMARY KEY ([Id])
);
GO

CREATE TABLE [Users] (
    [Id] nvarchar(450) NOT NULL,
    [FullName] nvarchar(100) NOT NULL,
    [Role] nvarchar(20) NOT NULL,
    [CreatedAt] datetime2 NOT NULL,
    [LastLogin] datetime2 NULL,
    [UserName] nvarchar(256) NULL,
    [NormalizedUserName] nvarchar(256) NULL,
    [Email] nvarchar(256) NULL,
    [NormalizedEmail] nvarchar(256) NULL,
    [EmailConfirmed] bit NOT NULL,
    [PasswordHash] nvarchar(max) NULL,
    [SecurityStamp] nvarchar(max) NULL,
    [ConcurrencyStamp] nvarchar(max) NULL,
    [PhoneNumber] nvarchar(max) NULL,
    [PhoneNumberConfirmed] bit NOT NULL,
    [TwoFactorEnabled] bit NOT NULL,
    [LockoutEnd] datetimeoffset NULL,
    [LockoutEnabled] bit NOT NULL,
    [AccessFailedCount] int NOT NULL,
    CONSTRAINT [PK_Users] PRIMARY KEY ([Id])
);
GO

CREATE TABLE [CourtAvailabilities] (
    [AvailabilityID] int NOT NULL IDENTITY,
    [CourtID] int NOT NULL,
    [Date] date NOT NULL,
    [IsAvailable] bit NOT NULL,
    [Note] nvarchar(500) NULL,
    CONSTRAINT [PK_CourtAvailabilities] PRIMARY KEY ([AvailabilityID]),
    CONSTRAINT [FK_CourtAvailabilities_Courts_CourtID] FOREIGN KEY ([CourtID]) REFERENCES [Courts] ([CourtID]) ON DELETE CASCADE
);
GO

CREATE TABLE [TimeSlots] (
    [TimeSlotID] int NOT NULL IDENTITY,
    [CourtID] int NOT NULL,
    [DayOfWeek] int NOT NULL,
    [StartTime] time NOT NULL,
    [EndTime] time NOT NULL,
    CONSTRAINT [PK_TimeSlots] PRIMARY KEY ([TimeSlotID]),
    CONSTRAINT [FK_TimeSlots_Courts_CourtID] FOREIGN KEY ([CourtID]) REFERENCES [Courts] ([CourtID]) ON DELETE CASCADE
);
GO

CREATE TABLE [RoleClaims] (
    [Id] int NOT NULL IDENTITY,
    [RoleId] nvarchar(450) NOT NULL,
    [ClaimType] nvarchar(max) NULL,
    [ClaimValue] nvarchar(max) NULL,
    CONSTRAINT [PK_RoleClaims] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_RoleClaims_Roles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [Roles] ([Id]) ON DELETE CASCADE
);
GO

CREATE TABLE [Bookings] (
    [BookingID] int NOT NULL IDENTITY,
    [UserId] nvarchar(450) NOT NULL,
    [CourtID] int NOT NULL,
    [BookingDate] date NOT NULL,
    [StartTime] time NOT NULL,
    [EndTime] time NOT NULL,
    [TotalAmount] decimal(18,2) NOT NULL,
    [Status] nvarchar(20) NOT NULL,
    [CreatedAt] datetime2 NOT NULL,
    [Notes] nvarchar(500) NULL,
    CONSTRAINT [PK_Bookings] PRIMARY KEY ([BookingID]),
    CONSTRAINT [FK_Bookings_Courts_CourtID] FOREIGN KEY ([CourtID]) REFERENCES [Courts] ([CourtID]) ON DELETE CASCADE,
    CONSTRAINT [FK_Bookings_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Users] ([Id]) ON DELETE CASCADE
);
GO

CREATE TABLE [Notifications] (
    [NotificationID] int NOT NULL IDENTITY,
    [UserID] nvarchar(450) NOT NULL,
    [Message] nvarchar(500) NOT NULL,
    [CreatedAt] datetime2 NOT NULL,
    [IsRead] bit NOT NULL,
    CONSTRAINT [PK_Notifications] PRIMARY KEY ([NotificationID]),
    CONSTRAINT [FK_Notifications_Users_UserID] FOREIGN KEY ([UserID]) REFERENCES [Users] ([Id]) ON DELETE CASCADE
);
GO

CREATE TABLE [Reviews] (
    [ReviewID] int NOT NULL IDENTITY,
    [UserID] nvarchar(450) NOT NULL,
    [CourtID] int NOT NULL,
    [Rating] int NOT NULL,
    [Comment] nvarchar(1000) NULL,
    [CreatedAt] datetime2 NOT NULL,
    CONSTRAINT [PK_Reviews] PRIMARY KEY ([ReviewID]),
    CONSTRAINT [FK_Reviews_Courts_CourtID] FOREIGN KEY ([CourtID]) REFERENCES [Courts] ([CourtID]) ON DELETE CASCADE,
    CONSTRAINT [FK_Reviews_Users_UserID] FOREIGN KEY ([UserID]) REFERENCES [Users] ([Id]) ON DELETE CASCADE
);
GO

CREATE TABLE [UserClaims] (
    [Id] int NOT NULL IDENTITY,
    [UserId] nvarchar(450) NOT NULL,
    [ClaimType] nvarchar(max) NULL,
    [ClaimValue] nvarchar(max) NULL,
    CONSTRAINT [PK_UserClaims] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_UserClaims_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Users] ([Id]) ON DELETE CASCADE
);
GO

CREATE TABLE [UserLogins] (
    [LoginProvider] nvarchar(450) NOT NULL,
    [ProviderKey] nvarchar(450) NOT NULL,
    [ProviderDisplayName] nvarchar(max) NULL,
    [UserId] nvarchar(450) NOT NULL,
    CONSTRAINT [PK_UserLogins] PRIMARY KEY ([LoginProvider], [ProviderKey]),
    CONSTRAINT [FK_UserLogins_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Users] ([Id]) ON DELETE CASCADE
);
GO

CREATE TABLE [UserRoles] (
    [UserId] nvarchar(450) NOT NULL,
    [RoleId] nvarchar(450) NOT NULL,
    CONSTRAINT [PK_UserRoles] PRIMARY KEY ([UserId], [RoleId]),
    CONSTRAINT [FK_UserRoles_Roles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [Roles] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_UserRoles_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Users] ([Id]) ON DELETE CASCADE
);
GO

CREATE TABLE [UserTokens] (
    [UserId] nvarchar(450) NOT NULL,
    [LoginProvider] nvarchar(450) NOT NULL,
    [Name] nvarchar(450) NOT NULL,
    [Value] nvarchar(max) NULL,
    CONSTRAINT [PK_UserTokens] PRIMARY KEY ([UserId], [LoginProvider], [Name]),
    CONSTRAINT [FK_UserTokens_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Users] ([Id]) ON DELETE CASCADE
);
GO

CREATE TABLE [Payments] (
    [PaymentID] int NOT NULL IDENTITY,
    [BookingID] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [PaymentMethod] nvarchar(50) NOT NULL,
    [PaymentStatus] nvarchar(20) NOT NULL,
    [TransactionDate] datetime2 NOT NULL,
    CONSTRAINT [PK_Payments] PRIMARY KEY ([PaymentID]),
    CONSTRAINT [FK_Payments_Bookings_BookingID] FOREIGN KEY ([BookingID]) REFERENCES [Bookings] ([BookingID]) ON DELETE CASCADE
);
GO

CREATE INDEX [IX_Bookings_CourtID] ON [Bookings] ([CourtID]);
GO

CREATE INDEX [IX_Bookings_UserId] ON [Bookings] ([UserId]);
GO

CREATE INDEX [IX_CourtAvailabilities_CourtID] ON [CourtAvailabilities] ([CourtID]);
GO

CREATE INDEX [IX_Notifications_UserID] ON [Notifications] ([UserID]);
GO

CREATE UNIQUE INDEX [IX_Payments_BookingID] ON [Payments] ([BookingID]);
GO

CREATE INDEX [IX_Reviews_CourtID] ON [Reviews] ([CourtID]);
GO

CREATE INDEX [IX_Reviews_UserID] ON [Reviews] ([UserID]);
GO

CREATE INDEX [IX_RoleClaims_RoleId] ON [RoleClaims] ([RoleId]);
GO

CREATE UNIQUE INDEX [RoleNameIndex] ON [Roles] ([NormalizedName]) WHERE [NormalizedName] IS NOT NULL;
GO

CREATE INDEX [IX_TimeSlots_CourtID] ON [TimeSlots] ([CourtID]);
GO

CREATE INDEX [IX_UserClaims_UserId] ON [UserClaims] ([UserId]);
GO

CREATE INDEX [IX_UserLogins_UserId] ON [UserLogins] ([UserId]);
GO

CREATE INDEX [IX_UserRoles_RoleId] ON [UserRoles] ([RoleId]);
GO

CREATE INDEX [EmailIndex] ON [Users] ([NormalizedEmail]);
GO

CREATE UNIQUE INDEX [IX_Users_Email] ON [Users] ([Email]) WHERE [Email] IS NOT NULL;
GO

CREATE UNIQUE INDEX [UserNameIndex] ON [Users] ([NormalizedUserName]) WHERE [NormalizedUserName] IS NOT NULL;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'Name', N'CourtType', N'Location', N'HourlyRate', N'Description', N'Status', N'CreatedAt') AND [object_id] = OBJECT_ID(N'[Courts]'))
    SET IDENTITY_INSERT [Courts] ON;
INSERT INTO [Courts] ([CourtID], [Name], [CourtType], [Location], [HourlyRate], [Description], [Status], [CreatedAt])
VALUES (1, N'Sân 1', N'Indoor', N'Khu A', 80000.0, N'Sân đẹp', CAST(1 AS bit), '2024-01-01T00:00:00.0000000'),
(2, N'Sân 2', N'Indoor', N'Khu B', 80000.0, N'Sân đẹp', CAST(1 AS bit), '2024-01-01T00:00:00.0000000'),
(3, N'Sân 3', N'Outdoor', N'Khu C', 80000.0, N'Sân đẹp', CAST(1 AS bit), '2024-01-01T00:00:00.0000000');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'Name', N'CourtType', N'Location', N'HourlyRate', N'Description', N'Status', N'CreatedAt') AND [object_id] = OBJECT_ID(N'[Courts]'))
    SET IDENTITY_INSERT [Courts] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (1, 1, '07:00:00', '10:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (1, 1, '14:00:00', '17:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (1, 1, '17:00:00', '20:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (1, 1, '20:00:00', '22:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (1, 2, '07:00:00', '10:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (1, 2, '14:00:00', '17:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (1, 2, '17:00:00', '20:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (1, 2, '20:00:00', '22:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (1, 3, '07:00:00', '10:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (1, 3, '14:00:00', '17:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (1, 3, '17:00:00', '20:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (1, 3, '20:00:00', '22:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (1, 4, '07:00:00', '10:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (1, 4, '14:00:00', '17:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (1, 4, '17:00:00', '20:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (1, 4, '20:00:00', '22:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (1, 5, '07:00:00', '10:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (1, 5, '14:00:00', '17:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (1, 5, '17:00:00', '20:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (1, 5, '20:00:00', '22:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (1, 6, '07:00:00', '10:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (1, 6, '14:00:00', '17:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (1, 6, '17:00:00', '20:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (1, 6, '20:00:00', '22:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (1, 7, '07:00:00', '10:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (1, 7, '14:00:00', '17:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (1, 7, '17:00:00', '20:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (1, 7, '20:00:00', '22:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (2, 1, '07:00:00', '10:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (2, 1, '14:00:00', '17:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (2, 1, '17:00:00', '20:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (2, 1, '20:00:00', '22:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (2, 2, '07:00:00', '10:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (2, 2, '14:00:00', '17:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (2, 2, '17:00:00', '20:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (2, 2, '20:00:00', '22:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (2, 3, '07:00:00', '10:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (2, 3, '14:00:00', '17:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (2, 3, '17:00:00', '20:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (2, 3, '20:00:00', '22:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (2, 4, '07:00:00', '10:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (2, 4, '14:00:00', '17:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (2, 4, '17:00:00', '20:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (2, 4, '20:00:00', '22:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (2, 5, '07:00:00', '10:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (2, 5, '14:00:00', '17:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (2, 5, '17:00:00', '20:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (2, 5, '20:00:00', '22:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (2, 6, '07:00:00', '10:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (2, 6, '14:00:00', '17:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (2, 6, '17:00:00', '20:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (2, 6, '20:00:00', '22:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (2, 7, '07:00:00', '10:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (2, 7, '14:00:00', '17:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (2, 7, '17:00:00', '20:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (2, 7, '20:00:00', '22:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (3, 1, '07:00:00', '10:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (3, 1, '14:00:00', '17:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (3, 1, '17:00:00', '20:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (3, 1, '20:00:00', '22:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (3, 2, '07:00:00', '10:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (3, 2, '14:00:00', '17:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (3, 2, '17:00:00', '20:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (3, 2, '20:00:00', '22:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (3, 3, '07:00:00', '10:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (3, 3, '14:00:00', '17:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (3, 3, '17:00:00', '20:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (3, 3, '20:00:00', '22:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (3, 4, '07:00:00', '10:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (3, 4, '14:00:00', '17:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (3, 4, '17:00:00', '20:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (3, 4, '20:00:00', '22:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (3, 5, '07:00:00', '10:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (3, 5, '14:00:00', '17:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (3, 5, '17:00:00', '20:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (3, 5, '20:00:00', '22:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (3, 6, '07:00:00', '10:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (3, 6, '14:00:00', '17:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (3, 6, '17:00:00', '20:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (3, 6, '20:00:00', '22:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (3, 7, '07:00:00', '10:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (3, 7, '14:00:00', '17:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (3, 7, '17:00:00', '20:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] ON;
INSERT INTO [TimeSlots] ([CourtID], [DayOfWeek], [StartTime], [EndTime])
VALUES (3, 7, '20:00:00', '22:00:00');
IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourtID', N'DayOfWeek', N'StartTime', N'EndTime') AND [object_id] = OBJECT_ID(N'[TimeSlots]'))
    SET IDENTITY_INSERT [TimeSlots] OFF;
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250515144851_InitialCreate', N'8.0.11');
GO

COMMIT;
GO

