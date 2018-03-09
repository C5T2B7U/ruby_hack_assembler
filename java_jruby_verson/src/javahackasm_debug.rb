# BRIAN SUMNER
# UCDENVER CSCI 2940
# SPRING 2017
# NAND2TETRIS HACK ASSEMBLER
# NOTE: COMMANDLINE PARAMETERS DO NOT APPEAR TO WORK IN THIS JRUBYC .CLASS CONTRAPTION


# IMPORT LOGGER MODULE
require "logger"


# DEFINE COMMAND LINE USAGE
USAGE_STRING = "USAGE: ruby hackasm.rb {inputfile.asm} {outputfile.hack} [/DEBUG]"


# INIT GLOBAL LOGGER (USING /DEBUG SWITCH IF APPLICABLE)
$logger = Logger.new(STDOUT)
#if ARGV[2].to_s.upcase == "/DEBUG"
	$logger.level = Logger::DEBUG
#else
#	$logger.level = Logger::INFO
#end
$logger.formatter = proc do |severity, time, progname, msg|
	"#{severity}:\t #{msg}\n"
end
$DEBUG_SEPARATOR = "-------------------------------------------"


module Tabledefs
# DEFAULT DEFINITIONS TABLE MODULE
	C_PREFIX = "111"
	CTABLE = 
	{
		"0":   "0101010",
		"1":   "0111111",
		"-1":  "0111010",
		"D":   "0001100",
		"A":   "0110000",
		"!D":  "0001101",
		"!A":  "0110001",
		"-D":  "0001111",
		"-A":  "0110011",
		"D+1": "0011111",
		"1+D": "0011111",
		"A+1": "0110111",
		"1+A": "0110111",
		"D-1": "0001110",
		"A-1": "0110010",
		"D+A": "0000010",
		"A+D": "0000010",
		"D-A": "0010011",
		"A-D": "0000111",
		"A&D": "0000000",
		"D&A": "0000000",
		"A|D": "0010101",
		"D|A": "0010101",
		"M":   "1110000",
		"!M":  "1110001",
		"-M":  "1110011",
		"M+1": "1110111",
		"1+M": "1110111",
		"M-1": "1110010",
		"D+M": "1000010",
		"M+D": "1000010",
		"D-M": "1010011",
		"M-D": "1000111",
		"M&D": "1000000",
		"D&M": "1000000",
		"M|D": "1010101",
		"D|M": "1010101"
	}
	DTABLE = 
	{
		# NOTE: ASTERISK SHOULD USED INSTEAD OF EMPTY STRING
		"*":   "000",
#		"":    "000",
		"M":   "001",
		"D":   "010",
		"MD":  "011",
		"DM":  "011",
		"A":   "100",
		"AM":  "101",
		"MA":  "101",
		"AD":  "110",
		"DA":  "110",
		"AMD": "111",
		"ADM": "111",
		"DAM": "111",
		"DMA": "111",
		"MAD": "111",
		"MDA": "111"		
		}
	JTABLE =
	{
		# NOTE: ASTERISK SHOULD USED INSTEAD OF EMPTY STRING
		"*":   "000",
#		"":    "000",
		"JGT": "001",
		"JEQ": "010",
		"JGE": "011",
		"JLT": "100",
		"JNE": "101",
		"JLE": "110",
		"JMP": "111"
	}
	# DEFAULT SYMBOLS
	# NOTE: DEFAULT SYMBOLS ARE NOT CASE SENSITIVE
	SYMBOLS =
	{
		"R0":     0,
		"R1":     1,
		"R2":     2,
		"R3":     3,
		"R4":     4,
		"R5":     5,
		"R6":     6,
		"R7":     7,
		"R8":     8,
		"R9":     9,
		"R10":    10,
		"R11":    11,
		"R12":    12,
		"R13":    13,
		"R14":    14,
		"R15":    15,
		"SP":     0,
		"LCL":    1,
		"ARG":    2,
		"THIS":   3,
		"THAT":   4,
		"SCREEN": 16384,
		"KBD":    24576
	}
	# FIRST AVAILABLE RAM ADDRESS
	SYMBOLS_RAM_OFFSET = 16
end


class Tables
# LOCAL TABLES CLASS
	# INCLUDE DEFAULT TABLE ENTRIES
	include Tabledefs

	def initialize()
	# INIT TABLE OBJECT
		$logger.debug "INITIALIZING TABLES OBJECT"
		# INIT SYMBOL TABLE
		@symbols = {}
		# INIT C_STATEMENT CACHE
		@cCache = {}
		# INIT SYMBOL COUNTER FOR S_STATEMENT RAM ADDRESSES
		@symbolCounter = SYMBOLS_RAM_OFFSET
	end
	
	def is_comp_valid(comp)
	# DETERMINE IF C_STATEMENT COMP FIELD IS VALID
		return CTABLE.key?(comp.to_sym)
	end

	def is_dest_valid(dest)
	# DETERMINE IF C_STATEMENT DEST FIELD IS VALID
		return DTABLE.key?(dest.to_sym)
	end

	def is_jump_valid(jump)
	# DETERMINE IF C_STATEMENT JUMP FIELD IS VALID
		return JTABLE.key?(jump.to_sym)
	end

	def get_comp(comp)
	# RETRIEVE C_STATEMENT COMP FIELD ENTRY VALUE FROM TABLE
		return CTABLE[comp.to_sym]
	end

	def get_dest(dest)
	# RETRIEVE C_STATEMENT DEST FIELD ENTRY VALUE FROM TABLE
		return DTABLE[dest.to_sym]
	end

	def get_jump(jump)
	# RETRIEVE C_STATEMENT JUMP FIELD ENTRY VALUE FROM TABLE
		return JTABLE[jump.to_sym]
	end

	def cache_c_statement(statement, dest, comp, jump)
	# STORE VALIDATED C_STATEMENT AND MACHINE INSTRUCTION IN CACHE TABLE
		# TEST IF C_STATEMENT ALREADY CACHED
		if @cCache.key?(statement.to_sym)
			$logger.debug "C_STATEMENT ALREADY CACHED AS:\t #{@cCache[statement.to_sym]}"
		else
			# CACHE C_STATEMENT
			@cCache[statement.to_sym] = C_PREFIX + get_comp(comp) + get_dest(dest) + get_jump(jump)
			$logger.debug "C_STATEMENT CACHED WITH VALUE:\t #{@cCache[statement.to_sym]}"
		end
	end
	
	def get_cached_c_instruction(statement)
	# RETRIEVE CACHED C_STATEMENT MACHINE INSTRUCTION
		return @cCache[statement.to_sym]
	end

	def add_symbol(symbol)
	# ADD S_STATEMENT SYMBOL TO TABLE
		if SYMBOLS.key?(symbol.upcase.to_sym) 
			# DO NOT OVERRIDE DEFAULT SYMBOLS WITH DIFFERENT CASE SYMBOLS
			# NOTE: DEFAULT SYMBOLS ARE NOT CASE SENSITIVE
			$logger.debug "DEFSYM ALREADY EXISTS AS:\t #{SYMBOLS[symbol.upcase.to_sym]}"
		elsif @symbols.key?(symbol.to_sym)
			# DO NOT ADD IF CASE SENSITIVE SYMBOL IS ALREADY IN TABLE
			$logger.debug "SYMBOL ALREADY EXISTS AS:\t #{@symbols[symbol.to_sym]}"
		else
			# ADD SYMBOL AS NEXT AVAILABLE RAM ADDRESS
			@symbols[symbol.to_sym] = @symbolCounter
			# INCREMENT SYMBOL COUNTER 
			@symbolCounter += 1
			$logger.debug "SYMBOL ADDED WITH VALUE:\t #{@symbols[symbol.to_sym]}"
		end
	end

	def add_label(label, value)
	# ADD L_STATEMENT LABEL SYMBOL TO TABLE
		$logger.debug "ADDING LABEL TO TABLE: \t #{label}"
		if SYMBOLS.key?(label.upcase.to_sym) 
			# DO NOT ADD LABEL IF LABEL IS A DEFAULT SYMBOL
			# NOTE: DEFAULT SYMBOLS ARE NOT CASE SENSITIVE
			$logger.debug "DEFSYM ALREADY EXISTS AS:\t #{SYMBOLS[label.upcase.to_sym]}"
		elsif @symbols.key?(label.to_sym)
			# DO NOT ADD IF LABEL IS ALREADY A CASE SENSITIVE SYMBOL IN TABLE
			$logger.debug "LABEL ALREADY EXISTS AS:\t #{@symbols[label.to_sym]}"
		else
			# ADD LABEL AS VALUE PASSED BY PARAMETER
			# NOTE: DO NOT INCREMENT SYMBOL COUNTER
			@symbols[label.to_sym] = value
			$logger.debug "LABEL ADDED WITH VALUE:\t #{@symbols[label.to_sym]}"
		end
	end

	def get_symbol_value(symbol)
	# GET S_STATEMENT OR L_STATEMENT SYMBOL FROM TABLE
		if SYMBOLS.key?(symbol.upcase.to_sym)
			# RETRIEVE DEFAULT SYMBOL IF EXISTS IN DEFAULT SYMBOL TABLE
			return SYMBOLS[symbol.upcase.to_sym]
		elsif @symbols.key?(symbol.to_sym)
			# RETRIEVE SYMBOL FROM TABLE IF EXISTS
			return @symbols[symbol.to_sym]
		else
			# HANDLE POTENTIAL UNKNOWN ERROR
			$logger.fatal "UNKNOWN ERROR - RETRIEVING NON-EXISTING SYMBOL"
			raise "RETRIEVING NON-EXISTING SYMBOL:\t #{symbol}"
		end
	end
end
# END Tables CLASS


def get_statement_type(statement, tables)
# VALIDATE STATEMENT; CACHE C_STATEMENT INSTRUCTION; RETURN STATEMENT TYPE
	# INIT OUTPUT WITH DEFAULT VALUE
	statementType = "INVALID_STATEMENT"

	# TEST FOR GLOBALLY INVALID CHARACTERS
	# NOTE: REGEX MATCHES FIRST CHARACTER NOT VALID FOR ANY STATEMENT TYPE
	if statement[/[^[0-9][a-z][A-Z][\@\_\.\$\:][\(\)][\=\;\+\-\|\&\!]]/] != nil
		$logger.fatal "INVALID CHARACTERS:\t #{statement}"
	else

		# TEST L_STATEMENT
		if statement.start_with?("(") and statement.end_with?(")")
			$logger.debug "TESTING L_STATEMENT:\t\t #{statement}"
			# STRIP PARENS
			testStatement = statement[1..-2]
			# TEST FOR LOCALLY INVALID CHARACTERS
			if testStatement[/[[\(\)][\=\;\+\-\|\&\!]]/] == nil
				statementType = "L_STATEMENT"
			else 
				$logger.fatal "INVALID CHARACTER(S):  #{statement}"
			end
			
		# TEST A_STATEMENT OR S_STATEMENT
		elsif statement.start_with?("@")
			testStatement = statement[1..-1]
			
			# TEST FOR A_STATEMENT OR S_STATEMENT
			if testStatement[/[^[0-9]]/] == nil
				$logger.debug "TESTING A_STATEMENT:\t\t #{statement}"
				# TEST FOR A_STATEMENT OUT OF RANGE
				if testStatement.to_i >= 0 and testStatement.to_i < 32768
					statementType = "A_STATEMENT"
				else
					$logger.fatal "A_STATEMENT OUT OF RANGE 0-32767  [#{statement}]"
				end
			else
				$logger.debug "TESTING S_STATEMENT:\t\t #{statement}"
			
				# TEST S_STATEMENT FOR LOCALLY INVALID CHARACTERS
				if testStatement[/[[\(\)][\=\;\+\-\|\&\!]]/] == nil
					statementType = "S_STATEMENT"
				else 
					$logger.fatal "INVALID CHARACTER(S):  #{statement}"
				end

			end
		# TEST C_STATEMENT
		else
			statement = statement.upcase
			$logger.debug "TESTING C_STATEMENT:\t\t #{statement}"
			# TEST FOR LOCALLY INVALID CHARACTERS
			if statement[/[[\@\_\.\$\:][\(\)]]/] != nil
				$logger.fatal "INVALID CHARACTER(S):  #{statement}"
			else
				# SPLIT STATEMENT INTO ["DEST", "COMP;JUMP"]
				splitEQ = statement.split("=")
				# SPLIT STATEMENT INTO ["DEST=COMP", "JUMP"]
				splitSC = statement.split(";")
#				$logger.debug "SPLITSC = #{splitSC}"
#				$logger.debug "SPLITEQ = #{splitEQ}"

				# TEST FOR MULTIPLE = OR ; CHARACTERS
				if splitSC.length > 2 or splitEQ.length > 2
					$logger.fatal "SYNTAX ERROR:  #{statement}"
				else
					# SPLIT "DEST=COMP" INTO ["DEST", "COMP"]
					splitSCEQ = splitSC[0].split("=")
					# PUSH "JUMP" INTO ["DEST", "COMP"]
					if splitSC.length == 2
						splitSCEQ.push splitSC[1]
					end
#					$logger.debug "SPLITSCEQ = #{splitSCEQ}"

					# CASE: DEST=COMP;JUMP
					if splitSCEQ.length == 3
						# TEST FOR VALID C_STATEMENT
						if tables.is_dest_valid(splitSCEQ[0]) and tables.is_comp_valid(splitSCEQ[1]) and tables.is_jump_valid(splitSCEQ[2])
							$logger.debug "VALID C_STATEMENT OF TYPE:\t [DEST=COMP;JUMP]"
							statementType = "C_STATEMENT"
							# CACHE C_STATEMENT OF KNOWN TYPE FOR OPTIMAL PERFORMANCE DURING PARSING
							tables.cache_c_statement(statement, splitSCEQ[0], splitSCEQ[1], splitSCEQ[2])
						else
							$logger.fatal "SYNTAX ERROR:  #{statement}"
						end
					# CASE: DEST=COMP
					elsif splitSCEQ.length == 2 and splitEQ.length == 2
						# TEST FOR VALID C_STATEMENT
						if tables.is_dest_valid(splitSCEQ[0]) and tables.is_comp_valid(splitSCEQ[1])
							$logger.debug "VALID C_STATEMENT OF TYPE:\t [DEST=COMP]"
							statementType = "C_STATEMENT"
							# CACHE C_STATEMENT OF KNOWN TYPE FOR OPTIMAL PERFORMANCE DURING PARSING
							tables.cache_c_statement(statement, splitSCEQ[0], splitSCEQ[1], "*")
						else
							$logger.fatal "SYNTAX ERROR:  #{statement}"
						end
					# CASE: COMP;JUMP
					elsif splitSCEQ.length == 2 and splitSC.length == 2
						# TEST FOR VALID C_STATEMENT
						if tables.is_comp_valid(splitSCEQ[0]) and tables.is_jump_valid(splitSCEQ[1])
							$logger.debug "VALID C_STATEMENT OF TYPE:\t [COMP;JUMP]"
							statementType = "C_STATEMENT"
							# CACHE C_STATEMENT OF KNOWN TYPE FOR OPTIMAL PERFORMANCE DURING PARSING
							tables.cache_c_statement(statement, "*", splitSCEQ[0], splitSCEQ[1])
						else
							$logger.fatal "SYNTAX ERROR:  #{statement}"
						end
					# CASE: COMP
					elsif splitSCEQ.length == 1
						# TEST FOR VALID C_STATEMENT
						if tables.is_comp_valid(splitSCEQ[0])
							$logger.debug "VALID C_STATEMENT OF TYPE:\t [COMP]"
							statementType = "C_STATEMENT"
							# CACHE C_STATEMENT OF KNOWN TYPE FOR OPTIMAL PERFORMANCE DURING PARSING
							tables.cache_c_statement(statement, "*", splitSCEQ[0], "*")
						else
							$logger.fatal "SYNTAX ERROR:  #{statement}"
						end
					# CASE: INVALID C_STATEMENT
					else
						$logger.fatal "SYNTAX ERROR:  #{statement}"
					end
				end
			end
		end
	end
	# RETURN STATEMENT TYPE
	return statementType
end


def parser(line, tables)
# PARSE VALID STATEMENTS
	# INIT OUTPUT
	machineInstruction = ""
	# STRIP STATEMENT TYPE CODE
	statement = line[1..-1]
	
	# IDENTIFY STATEMENT TYPE
	case line[0]
		when "A"
			$logger.debug "PARSING A_STATEMENT:\t\t @#{statement}"
			# OUTPUT 16-BIT BINARY MACHINE INSTRUCTION FROM VALUE
			machineInstruction = ("%016b" % statement.to_i).to_s
		when "S"
			$logger.debug "PARSING S_STATEMENT:\t\t @#{statement}"
			# ATTEMPT TO ADD S_STATEMENT SYMBOL TO TABLE
			tables.add_symbol(line[1..-1])
			# RETRIEVE S_STATEMENT SYMBOL VALUE FROM TABLE
			# NOTE: S_STATEMENT SYMBOL IS GUARANTEED TO BE IN TABLE
			value = tables.get_symbol_value(statement)
			# OUTPUT 16-BIT BINARY MACHINE INSTRUCTION FROM VALUE
			machineInstruction = ("%016b" % value.to_i).to_s
		when "C"
			$logger.debug "PARSING C_STATEMENT:\t\t #{statement}"
			# RETRIEVE CACHED INSTRUCTION FOR C_STATEMENT
			machineInstruction = tables.get_cached_c_instruction(statement)
	end
	# RETURN ASSEMBLED MACHINE INSTRUCTION
	return machineInstruction
end


def run_assembler()
# RUN ASSEMBLER PROGRAM

	$logger.debug $DEBUG_SEPARATOR
	$logger.debug "DISPLAYING COMMANDLINE PARAMETER DATA:"
	$logger.debug "ARGV.length = #{ARGV.length}"
	$logger.debug "ARGV[0] = #{ARGV[0]}"
	$logger.debug "ARGV[1] = #{ARGV[1]}"
	$logger.debug "ARGV[2] = #{ARGV[2]}"

	$logger.info $DEBUG_SEPARATOR
	$logger.info "SUMNERBR:  HACK ASSEMBLER FOR RUBY FOR JAVA"
	$logger.info $DEBUG_SEPARATOR

	# INIT TABLES
	tables = Tables.new
		

	# TRY TO OPEN FILES USING COMMAND LINE PARAMETERS
	begin
		$logger.debug "ATTEMPTING TO OPEN FILES"
		
		puts "ENTER SOURCE ASM FILENAME:"
		iFileName = gets
		iFile = File.new(iFileName[0..-2], 'r')
		puts "ENTER OUTPUT HACK FILENAME:"
		oFileName = gets
		oFile = File.new(oFileName[0..-2], 'w')
#		puts "TO ENABLE DEBUG MODE, ENTER:  DEBUG"
#		chooseDebug = gets
		
#		if chooseDebug.upcase == "DEBUG"
#			$logger.level = Logger::DEBUG
#			logDebug = File.new(oFileName + ".log", 'w')
#		end
		
#		iFile = File.new(ARGV[0], 'r')
#		oFile = File.new(ARGV[1], 'w')
	rescue
		# DISPLAY COMMAND LINE USAGE STRING IF FILE ERROR
		raise "FILE ERROR\n\n" + USAGE_STRING
		exit
	end

	$logger.info $DEBUG_SEPARATOR
	$logger.info "BEGINNING HACK ASSEMBLER EXECUTION."
	$logger.info $DEBUG_SEPARATOR

	
	# READ INPUT FILE INTO INDIVIDUAL LINES AND CLOSE FILE
	lines = iFile.read.split("\n")
	iFile.close
	$logger.debug "FINISHED READING INPUT FILE"
	$logger.debug $DEBUG_SEPARATOR
	
	
	# INIT LIST OF VALID LINES FOR PARSING
	parseLines = []
	
	
	# FOR EACH LINE DO FIRST PASS
	$logger.debug "STARTING FIRST PASS"
	lines.each do |line|
	
		# STRIP WHITESPACE AND COMMENTS
		line = line.gsub(/\s+/, "").gsub(/\/\/(.*)/, "")  

		# SKIP BLANK OR COMMENT LINES
		if line != ""
		
			# GET STATEMENT TYPE.  POSSIBLE TYPES ARE:
				# A_STATEMENT => IS @INTEGER_CONSTANT
				# S_STATEMENT => IS @SYMBOL
				# L_STATEMENT => IS (LABEL)
				# C_STATEMENT
				# INVALID_STATEMENT
			statementType = get_statement_type(line, tables)
			
			# APPEND STATEMENT TO CONTROL CODE AND PUSH LINE
			# NOTE: CONTROL CODE PREVENTS NEED FOR DETERMINING STATEMENT TYPE IN SECOND PASS
			case statementType 
				when "A_STATEMENT"
					parseLines.push("A" + line[1..-1])
				when "S_STATEMENT"
					parseLines.push("S" + line[1..-1])
				when "L_STATEMENT"
					tables.add_label(line[1..-2], parseLines.length)
				when "C_STATEMENT"
					parseLines.push("C" + line.upcase)
				else
					raise "INVALID STATEMENT:  #{line}"
			end
		end
	end
	$logger.debug "FINISHED FIRST PASS"
	$logger.debug $DEBUG_SEPARATOR
	
	
	# FOR EACH VALID LINE IN PARSE LIST DO SECOND PASS
	$logger.debug "STARTING SECOND PASS"
	machineInstruction = ""
	parseLines.each_with_index do |line, index|


		# PARSE STATEMENT
		machineInstruction = parser(line, tables)

		
		# REFORMAT STATEMENT BY TYPE
		case line[0]
			when "C"
				# STRIP STATEMENT TYPE CODE FROM STATEMENT
				statement = line[1..-1]
			when "A", "S"
				# APPEND STRIPPED STATEMENT TO @ CHARACTER
				statement = "@" + line[1..-1] 
		end
		

		# DISPLAY MACHINE INSTRUCTION TO CONSOLE WITH PADDING
		padding = " "
		if statement.length < 24
			padding = " " * (24-statement.length)
		end
		$logger.info "#{statement} =" + padding + " #{machineInstruction}"
		
		
		# WRITE MACHINE INSTRUCTION TO HACK FILE
		oFile.write(machineInstruction)
		
		
		# WRITE NEWLINE IF NOT LAST STATEMENT IN PARSE LIST
		if index != parseLines.length-1
			oFile.write("\n")
		end
	end
	
	
	# CLOSE OUTPUT FILE
	oFile.close
	
	$logger.info $DEBUG_SEPARATOR
	$logger.info "HACK ASSEMBLER EXECUTION COMPLETE."
	$logger.info $DEBUG_SEPARATOR

end


# BEGIN PROGRAM EXECUTION ATTEMPT
begin
	run_assembler
rescue Exception => exceptionMsg
	puts "\n\nFATAL ERROR:  #{exceptionMsg}\n\n"
end


# END OF FILE