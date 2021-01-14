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
	JSONToCSV (JSONArrayAux: JSON_ARRAY): STRING

		local
			line: STRING
			tipos: BOOLEAN
			lineAux2: STRING
			lineTipos: STRING
			lineResult: STRING
			lineNombres: STRING
			listaAux: LINKED_LIST [STRING]
		do
			tipos := TRUE
			create listaAux.make
			create line.make_empty
			create lineTipos.make_empty
			create lineResult.make_empty
			create lineNombres.make_empty

			across JSONArrayAux as tira
			loop
				line := tira.item.representation
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
						lineNombres := column.item.split (':').at (2)
						if lineNombres.head(1).is_equal ("%"") then
							lineTipos.append ("X;")
						elseif lineNombres.head(1).is_equal ("t") or lineNombres.head(1).is_equal ("f") then
							lineTipos.append ("B;")
						else
							lineTipos.append ("N;")
						end
						lineNombres := column.item.split (':').at (1)
						lineNombres.replace_substring_all ("%"", "")
						lineResult.append (lineNombres + ";")
						lineNombres.wipe_out
					end
					lineAux2 := column.item.split (':').at (2)
					if lineAux2.is_equal ("true") then
						line.append ("S" + ";")
					elseif lineAux2.is_equal ("false") then
						line.append ("N" + ";")
					elseif lineAux2.is_equal ("null") then
						line.append ("" + ";")
					else
						line.append (lineAux2 + ";")
					end
				end
				listaAux.wipe_out
				lineTipos.remove_tail (1)
				if tipos then
					lineResult.remove_tail (1)
					lineResult.append ("%N")
					lineResult.append (lineTipos+"%N")
					tipos := FALSE
				end
				line.remove_tail (1)
				lineResult.append (line)
				lineResult.append ("%N")
				line.wipe_out
			end
			Result := lineResult
			Result.replace_substring_all ("%"", "")
		end

	selectRows (atributo: STRING valor: STRING JSONArrayAux: JSON_ARRAY): JSON_ARRAY
		local
			cont:INTEGER
			newJSON:JSON_ARRAY
			stringAux:STRING
			jsonStringAux:JSON_STRING
		do
			create newJSON.make_empty
			jsonStringAux:=atributo
			print(atributo+"%N")
			from
				cont:=1
			until
				cont=JSONArrayAux.count
			loop
				if attached {JSON_OBJECT} JSONArrayAux.i_th (cont) as jax2 then
			   		if jax2.has_key (jsonStringAux) then
		   				if attached {JSON_VALUE} jax2.item(jsonStringAux) as m then
		   					stringAux:=m.representation
		   					stringAux.replace_substring_all ("%"", "")
		   					if stringAux.is_equal (valor) then
		   						newJSON.extend (jax2)
		   						print(stringAux+"----"+valor+"%N")
		   					end
		   				end
			   		end
				end
				cont:=cont+1
			end
			Result:=newJSON
		end

	project(JSONArrayAux:JSON_ARRAY listaAtributos:LINKED_LIST[STRING]):JSON_ARRAY
	local
		cont:INTEGER
		newJSON:JSON_ARRAY
		objActual:JSON_OBJECT
		jsonStringAux:JSON_STRING
	do

		create newJSON.make_empty
		from
			cont:=1
		until
			cont=JSONArrayAux.count
		loop
			if attached {JSON_OBJECT} JSONArrayAux.i_th(cont) as jax then
				create objActual.make
				across listaAtributos as lisAux
				loop
					jsonStringAux:=lisAux.item.out
					if jax.has_key (jsonStringAux) then
						print(jax.representation)
						objActual.put (jax.item (jsonStringAux),jsonStringAux)
					end
				end
				newJSON.extend(objActual)
			end
			cont:=cont+1
		end
		Result:= newJSON
	end
	main_option_menu

		local
			in: INTEGER
			cont:INTEGER
			line: STRING
			valor: STRING
			lineAux: STRING
			JSONAux1: STRING
			JSONAux2: STRING
			atributo: STRING
			loadedFileName: STRING
			JSONArrayAux: JSON_ARRAY
			listaAux: LINKED_LIST[STRING]
			output_file: PLAIN_TEXT_FILE

		do

			from
				in := 0
			until
				in = 1
			loop

				io.read_line
				line := io.last_string
				lineAux := line.split (' ').at(1)
				if lineAux.is_equal ("load") then
					if not objetosJSON.has_key (line.split (' ').at (2)) then
					loadedFileName := line.split (' ').at (3)
					objetosJSON.extend (load (loadedFileName), line.split (' ').at (2))
					else
						print ("Ya existe el JSON especificado" + "%N")
					end
				elseif lineAux.is_equal ("save") then

					if objetosJSON.has_key (line.split (' ').at (2)) then
						create JSONArrayAux.make_empty
						create output_file.make_open_write (line.split (' ').at (3))
						JSONArrayAux := objetosJSON.at (line.split (' ').at (2))
						if JSONArrayAux /= void then
							line := JSONArrayAux.representation
						end
						line.to_string_8.replace_substring_all (",{", "," + "%N" + "{")
						line.replace_substring_all ("[", "[" + "%N")
						line.replace_substring_all ("]", "%N" + "]")
						output_file.put_string (line)
						output_file.close
						print ("Se ha guardado con éxito el archivo " + "%N")
					else
						print ("No existe el archivo especificado" + "%N")
					end

				elseif lineAux.is_equal ("savecsv") then
					if objetosJSON.has_key (line.split (' ').at (2)) then
						create JSONArrayAux.make_empty
						JSONArrayAux := objetosJSON.at (line.split (' ').at (2))
						create output_file.make_open_write (line.split (' ').at (3))

						if JSONArrayAux /= void then
							line := JSONToCSV (JSONArrayAux)
						end
						output_file.put_string (line)
						output_file.close
						print ("Se ha guardado con éxito el archivo " + "%N")
					else
						print ("No existe el archivo especificado" + "%N")
					end

				elseif lineAux.is_equal ("select") then
					JSONAux1 := line.split (' ').at (2)
					if objetosJSON.has_key (JSONAux1) then
						create JSONArrayAux.make_empty
						atributo := line.split (' ').at(4)
						JSONAux2 := line.split (' ').at(3)
						JSONArrayAux := objetosJSON.at(JSONAux1)
						valor:=""

						from
							cont:=6
						until
							cont= line.split (' ').count+1
						loop
							valor.append (line.split (' ').at (cont)+" ")
							cont:=cont+1
						end
						valor.replace_substring_all ("%"", "")
						valor.remove_tail (1)
						print(valor)
						if JSONArrayAux /= Void then
							JSONArrayAux := selectRows (atributo, valor, JSONArrayAux)
							objetosJSON.extend (JSONArrayAux, JSONAux2)
						end
						print ("Se ha creado la estructura con exito "+ "%N")
					else
						print ("La estructura no existe intentelo de nuevo")
					end

				elseif lineAux.is_equal ("project") then
					JSONAux1:=line.split (' ').at (2)
					JSONAux2:=line.split (' ').at (3)
					if objetosJSON.has_key (JSONAux2) then
						print("Ya existe la estructura JSON indicada %N")
					else
						create listaAux.make_from_iterable (line.split (' '))
						listaAux.remove_i_th (1)
						listaAux.remove_i_th (1)
						listaAux.remove_i_th (1)
						if listaAux.count < 1 then
							print("No se adjuntaron Atributos %N")
						else
							JSONArrayAux := objetosJSON.at (JSONAux1)
							if JSONArrayAux /= Void then
								JSONArrayAux := project(JSONArrayAux, listaAux)
								objetosJSON.extend (JSONArrayAux, JSONAux2)
							end
						end
					end

				elseif lineAux.is_equal ("exit") then
					in := 1
					print ("Proyecto 3 se está cerrando..." + "%N")
				else
					print ("Introdujo un comando erroneo" + "%N" + "%N")
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
			objetoActual:JSON_OBJECT
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
					create llave.make_from_string (csvActual.nombrescolumnas.at (index))
					tipo := csvActual.tiposcolumnas.at (index)
					if tipo.is_equal ("X") then
						if column.item.out.is_equal ("") then
							objetoActual.put (jsonNull, llave)
						else
						objetoActual.put_string (column.item.out, llave)
						end
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
