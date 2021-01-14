note
	description: "TP3 application root class"
	date: "$Date$"
	revision: "$Revision$"

class
	APPLICATION

inherit
	ARGUMENTS_32

create
	make

feature {NONE} -- Initialization

	objetosJSON: HASH_TABLE [JSON_ARRAY, STRING]

		--	MAIN
	make
		local

		do
			create objetosJSON.make (100)
			main_option_menu
		end

		-- Methods
	main_option_menu

		local
			in:INTEGER
			line: STRING
			lineAux: STRING
			loadedFileName: STRING
    		output_file: PLAIN_TEXT_FILE
    		j : JSON_ARRAY
		do

			from
				in:=0
			until
				in=1
			loop

				line := ""
				io.read_line
				line := io.last_string
				lineAux := line.split (' ').at (1)
				if lineAux.is_equal ("load") then
					loadedFileName := line.split (' ').at (3)
					objetosJSON.extend (load (loadedFileName), line.split (' ').at (2))


					line:=load (loadedFileName).representation.to_string_8
					line.replace_substring_all (",{", ","+"%N"+"{")


				elseif  lineAux.is_equal ("save") then

					if objetosJSON.has_key (line.split (' ').at (2)) then
						create j.make_empty
						create output_file.make_open_write (line.split (' ').at (3))
						j:=objetosJSON.at (line.split (' ').at (2))
						if j/= void then
							line := j.representation
						end
						line.to_string_8.replace_substring_all (",{", ","+"%N"+"{")
						output_file.put_string(line)
						output_file.close
					else
						print("No existe el archivo especificado"+"%N")
					end

				elseif lineAux.is_equal ("savecsv") then

				elseif lineAux.is_equal ("select") then

				elseif lineAux.is_equal ("project") then

				elseif lineAux.is_equal ("exit") then
					print ("Proyecto 3 se está cerrando..."+"%N")
					in:=1
				else
					print ("Introdujo un comando erroneo"+"%N"+"%N")
				end
			end
		end

	csv_to_json (csvActual: CSV_REP): JSON_ARRAY

		local
			jsonArray: JSON_ARRAY
			objetoActual: JSON_OBJECT
			index: INTEGER

			tipo: STRING
			llave: JSON_STRING
			realNum: REAL
			jsonNull:JSON_NULL

		do

			index := 0

			create Result.make_empty
			create jsonArray.make_empty
			across csvActual.filas as fila

			loop
				create objetoActual.make
				across fila.item
 					as column
				loop


					index := column.cursor_index
					create llave.make_from_string(csvActual.nombrescolumnas.at (index))
					tipo := csvActual.tiposcolumnas.at (index)
					if tipo.is_equal ("X") then
						if column.item.out.is_equal ("") then
								objetoActual.put (jsonNull, llave)
						end
						objetoActual.put_string(column.item.out, llave)
					elseif tipo.is_equal ("N") or tipo.is_equal ("9") then
						create realNum.make_from_reference (column.item.out.to_real)
						objetoActual.put_real (realNum, llave)
					elseif tipo.is_equal ("B") then
						if column.item.out.is_equal ("T") or column.item.out.is_equal ("S") then
							objetoActual.put_boolean (True, llave)
						elseif column.item.out.is_equal ("F") or column.item.out.is_equal ("N") then
							objetoActual.put_boolean (False, llave)
						end
					end


				end
				jsonArray.extend (objetoActual)
			end

			Result := jsonArray
		end


	load (fileName: STRING): JSON_ARRAY

		local
			line: STRING
			counter: INTEGER

			c: INTEGER
			csvCargado: CSV_REP
			input_file: PLAIN_TEXT_FILE
			filaActual: LINKED_LIST [STRING]
		do
			line := ""
			counter := 2
			c := 1
			create Result.make_empty
			create csvCargado.make
			create input_file.make_open_read (fileName)

			from
				input_file.read_line
			until
				input_file.end_of_file
			loop
				line := input_file.last_string

				if counter = 0 then
					create filaActual.make_from_iterable (line.split (';'))
					csvCargado.filas.extend (filaActual)
				elseif counter = 2 then
					counter := counter - 1
					csvCargado.nombrescolumnas.append (line.split (';'))
				else
					csvCargado.tiposColumnas.append (line.split (';'))
					counter := counter - 1
				end
				input_file.read_line
			end
			input_file.close
			Result := csv_to_json (csvCargado)
		end

end
