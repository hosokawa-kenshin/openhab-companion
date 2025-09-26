CREATE TABLE Beacon(
  ID int primary key,
  UUID char(36),
  Major int,
  Minor int,
  TxPower int,
  Description varchar(255)
);

CREATE TABLE Mediator(
  ID int primary key,
  UID varchar(20),
  Room varchar(10),
  X_Coordinate double,
  Y_Coordinate double,
  Z_Coordinate double,
  Description varchar(255)
);

CREATE TABLE Signal (
  ID int PRIMARY KEY,
  BeaconUUID char(36),
  MediatorUID varchar(20),
  RSSI int,
  Timestamp datetime,
  Description varchar(255),
);

CREATE INDEX IF NOT EXISTS idx_signal_timestamp ON Signal(Timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_signal_beacon_timestamp ON Signal(BeaconUUID, Timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_signal_beacon_rssi ON Signal(BeaconUUID, RSSI DESC);
CREATE INDEX IF NOT EXISTS idx_signal_mediator ON Signal(MediatorUID);
