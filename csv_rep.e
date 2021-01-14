note
	description: "Summary description for {CSV_REP}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CSV_REP

create
	make
feature

	tiposColumnas: LINKED_LIST[STRING]
	nombresColumnas: LINKED_LIST[STRING]
	filas: LINKED_LIST[ LINKED_LIST[STRING] ]

	make
		do
			create filas.make
			create tiposColumnas.make
			create nombresColumnas.make
		end


end
