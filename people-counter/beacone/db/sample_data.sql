-- Beaconテーブルのデータ
INSERT INTO Beacon (ID, UUID, Major, Minor, TxPower, Description)
VALUES
('1', 'df3a8a50-01ab-4f24-8fa9-9631bc872345', 2, 300, -60, 'tanaka'),
('2', 'f3a2b8d0-1234-4bd9-8fb8-524ae8b9056d', 2, 301, -65, 'suzuki'),
('3', '92c377aa-4e56-485b-81e7-8fd0ecb89c12', 2, 302, -62, 'yamada'),
('4', 'bc194b98-6f4e-41c1-b3cb-1b132b90789a', 2, 303, -64, 'kobayashi'),
('5', '13a2e8fa-b24b-4852-b2f0-13c2cb89a123', 2, 304, -63, 'nakajima'),
('6', '24c4e8fa-d344-4893-b3f0-15f3cb89a987', 2, 305, -61, 'matsumoto'),
('7', '18c2e8fa-a44a-4921-b1d0-09b1cb89b098', 2, 306, -66, 'inoue'),
('8', 'e29a32f8-c543-493d-b6a4-05b6cb89d543', 2, 307, -58, 'saito'),
('9', 'd39e82b9-a6b4-4e57-b234-65b4cb89a543', 2, 308, -64, 'takahashi'),
('10', '2d4f72e5-f123-4dbe-b034-75f5cb89e234', 2, 309, -65, 'kato'),
('11', '6b3f97b9-c342-4f23-b546-45f3cb89c123', 2, 310, -63, 'murakami'),
('12', 'a1d4e0b2-5c23-4d34-a456-55f6cb89e654', 2, 311, -67, 'ishikawa');

-- Mediatorテーブルのデータ
INSERT INTO Mediator (ID, UID, Room, X_Coordinate, Y_Coordinate, Z_Coordinate, Description)
VALUES
('1', 'blescanner-123abc', 'room201', 1.5, 2.0, 0.0, 'Meeting Room A'),
('2', 'blescanner-456def', 'room202', -2.0, 1.0, 0.5, 'Office Space 1'),
('3', 'blescanner-789ghi', 'room203', -1.0, -1.5, 0.3, 'Break Area'),
('4', 'blescanner-101jkl', 'room204', 2.0, 2.5, 0.1, 'Conference Room'),
('5', 'blescanner-202mno', 'room205', 0.0, 0.0, 0.0, 'Reception Area'),
('6', 'blescanner-303pqr', 'room301', 3.0, 3.0, 0.0, 'Executive Office');