CREATE NONCLUSTERED INDEX NONCI_Regist ON [dbo].[ClosedGrades]
(
	[registid] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX NONCI_Grade ON [dbo].[ClosedGrades]
(
	[grade3] ASC,
	[registid] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX NONCI_SchStd ON [dbo].[ClosedRegistrations]
(
	[idSchoolStudent] ASC,
	[id] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX NONCI_Year ON [dbo].[SchoolStudent]
(
	[schoolYear] ASC,
	[id] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX NONCI_SchoolYear ON [dbo].[SchoolStudent]
(
	[id] ASC,
	[idSchool] ASC,
	[schoolYear] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]