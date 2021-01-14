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

	-- METHODS
	JSONToCSV(JSONArrayAux: JSON_ARRAY): STRING

	local
		line:STRING
		tipos:BOOLEAN
		lineAux2:STRING
		lineTipos:STRING
		lineResult:STRING
		lineNombres:STRING
		listaAux:LINKED_LIST[STRING]
	do
		tipos:= TRUE
		create listaAux.make
		create line.make_empty
		create lineTipos.make_empty
		create lineResult.make_empty
		create lineNombres.make_empty

		across JSONArrayAux as tira
		loop
			line:=tira.item.representation
			line.remove_head (1)
			if line.tail (1).is_equal (",") then
				line.remove_tail (2)
			else
				line.remove_tail (1)
			end
			listaAux.append (line.split (','))
			line.wipe_out
			across listaAux as column
			loop
				if tipos then
					lineAux2:=column.item.split (':').at(1)
					lineAux2.replace_substring_all ("%"","")
					lineResult.append (lineAux2+";")
					lineAux2.wipe_out
				end
				lineAux2:= column.item.split (':').at (2)
				if lineAux2.is_equal ("true") then
					line.append ("S"+";")
				elseif  lineAux2.is_equal("false") then
					line.append ("N"+";")
				else
					line.append (lineAux2+";")
				end
			end
			listaAux.wipe_out
			if tipos then
				lineResult.remove_tail (1)
				lineResult.append ("%N")
				tipos:=FALSE
			end
			line.remove_tail (1)
			lineResult.append (line)
			lineResult.append ("%N")
			line.wipe_out
		end
		Result:=lineResult
		Result.replace_substring_all ("%"","")
	end


	main_option_menu

		local
			in:INTEGER
			line: STRING
			lineAux: STRING
			loadedFileName: STRING
			JSONArrayAux : JSON_ARRAY
    		output_file: PLAIN_TEXT_FILE

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
						create JSONArrayAux.make_empty
						create output_file.make_open_write (line.split (' ').at (3))
						JSONArrayAux:=objetosJSON.at (line.split (' ').at (2))
						if JSONArrayAux/= void then
							line := JSONArrayAux.representation
						end
						line.to_string_8.replace_substring_all (",{", ","+"%N"+"{")
						line.replace_substring_all ("[", "["+"%N")
						line.replace_substring_all ("]", "%N"+"]")
						output_file.put_string(line)
						output_file.close
					else
						print("No existe el archivo especificado"+"%N")
					end

				elseif lineAux.is_equal ("savecsv") then
					if objetosJSON.has_key (line.split (' ').at (2)) then
						create JSONArrayAux.make (4)
						create output_file.make_open_write (line.split (' ').at (3))
						JSONArrayAux:=objetosJSON.at (line.split (' ').at (2))

						if JSONArrayAux/= void then
							line:=JSONToCSV(JSONArrayAux)
						end
						output_file.put_string(line)
						output_file.close
					else
						print("No existe el archivo especificado"+"%N")
					end
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
			tipo: STRING
			index: INTEGER
			llave: JSON_STRING
			jsonNull: JSON_NULL
			jsonArray: JSON_ARRAY
			objetoActual: JSON_OBJECT
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
						if  column.item.out.is_equal ("") then
							objetoActual.put (jsonNull, llave)
						end
						objetoActual.put_string(column.item.out, llave)
					elseif tipo.is_equal ("N") or tipo.is_equal ("9") then
						objetoActual.put_real (column.item.out.to_real, llave)
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
			c: INTEGER
			line: STRING
			counter: INTEGER
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
