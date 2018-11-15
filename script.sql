----- bit mapping function ---------------------------------------------------------
CREATE FUNCTION [dbo].[geohash_bit] (
    @_bit TINYINT 
)
RETURNS TINYINT 
AS
BEGIN
    DECLARE @bit TINYINT

    SET @bit = CASE @_bit
        WHEN 0 THEN 16
        WHEN 1 THEN 8
        WHEN 2 THEN 4
        WHEN 3 THEN 2
        WHEN 4 THEN 1
    END

    RETURN @bit;
end

-----base 32 reverse mapping function ------------------------------------------------
CREATE FUNCTION [dbo].[geohash_base32_index] (
    @ch CHAR(1)
)
RETURNS TINYINT
AS
BEGIN
    DECLARE @idx TINYINT

     SET @idx = CASE @ch
        WHEN '0' THEN 0
        WHEN '1' THEN 1
        WHEN '2' THEN 2
        WHEN '3' THEN 3
        WHEN '4' THEN 4
        WHEN '5' THEN 5
        WHEN '6' THEN 6
        WHEN '7' THEN 7
        WHEN '8' THEN 8
        WHEN '9' THEN 9
        WHEN 'b' THEN 10
        WHEN 'c' THEN 11
        WHEN 'd' THEN 12
        WHEN 'e' THEN 13
        WHEN 'f' THEN 14
        WHEN 'g' THEN 15
        WHEN 'h' THEN 16
        WHEN 'j' THEN 17
        WHEN 'k' THEN 18
        WHEN 'm' THEN 19
        WHEN 'n' THEN 20
        WHEN 'p' THEN 21
        WHEN 'q' THEN 22
        WHEN 'r' THEN 23
        WHEN 's' THEN 24
        WHEN 't' THEN 25
        WHEN 'u' THEN 26
        WHEN 'v' THEN 27
        WHEN 'w' THEN 28
        WHEN 'x' THEN 29
        WHEN 'y' THEN 30
        WHEN 'z' THEN 31
	end
    RETURN @idx;
END

-----base 32 mapping function ---------------------------------------------------------
CREATE FUNCTION [dbo].[geohash_base32] (
    @_index TINYINT 
)
RETURNS CHAR(1)
AS
BEGIN
    DECLARE @ch CHAR(1)

   set @ch = CASE @_index
        WHEN 0 THEN '0'
        WHEN 1 THEN '1'
        WHEN 2 THEN '2'
        WHEN 3 THEN '3'
        WHEN 4 THEN '4'
        WHEN 5 THEN '5'
        WHEN 6 THEN '6'
        WHEN 7 THEN '7'
        WHEN 8 THEN '8'
        WHEN 9 THEN '9'
        WHEN 10 THEN 'b'
        WHEN 11 THEN 'c'
        WHEN 12 THEN 'd'
        WHEN 13 THEN 'e'
        WHEN 14 THEN 'f'
        WHEN 15 THEN 'g'
        WHEN 16 THEN 'h'
        WHEN 17 THEN 'j'
        WHEN 18 THEN 'k'
        WHEN 19 THEN 'm'
        WHEN 20 THEN 'n'
        WHEN 21 THEN 'p'
        WHEN 22 THEN 'q'
        WHEN 23 THEN 'r'
        WHEN 24 THEN 's'
        WHEN 25 THEN 't'
        WHEN 26 THEN 'u'
        WHEN 27 THEN 'v'
        WHEN 28 THEN 'w'
        WHEN 29 THEN 'x'
        WHEN 30 THEN 'y'
        WHEN 31 THEN 'z'
    END

    RETURN @ch;
END
-----Shift Right funciton needed to decode---------------------------------------------- 
CREATE FUNCTION [dbo].[shiftRight] (
	@x	INT,
	@s	INT
)
	RETURNS int
AS
begin
	declare @y int
	declare @pow int
	set @pow = POWER(CAST(2 AS BIGINT), @s & 0x1F)

	if @x >= 0 
		set @y = CAST(@x / @pow AS INT)
	else
		set @y = CAST(~@x / @pow AS INT)
	return @y;
	end
GO


----Actual decode function---------------------------------------------------------------
CREATE FUNCTION [dbo].[decode_geohash] (
     @_geohash VARCHAR(12)
)
RETURNS VARCHAR(256)
AS
BEGIN
    DECLARE @latMin decimal(10, 7)
    DECLARE @latMax decimal(10, 7)
	SET @latMin = -90.0
	SET @latMax = 90.00

    DECLARE @lonMin decimal(10, 7)
    DECLARE @lonMax decimal(10, 7)
	SET @lonMin = -180.0
	SET @lonMax = 180.0

    DECLARE @chr CHAR(1)
    DECLARE @idx INT
	set @idx = 0

    DECLARE @even BIT
	set @even = 1
    DECLARE @geohash_length TINYINT
	set @geohash_length = 0
    DECLARE @geohash_pos TINYINT
	SET @geohash_pos = 0
    DECLARE @n int

    DECLARE @buf VARCHAR(77)

    SET @geohash_length = LEN(@_geohash);
    WHILE @geohash_pos < @geohash_length
	begin
        SET @chr = SUBSTRING(@_geohash, @geohash_pos + 1, 1)
        SET @idx = dbo.geohash_base32_index(@chr);
		SET @n = 4;
        WHILE @n >= 0
		begin
			DECLARE  @bitN tinyint
			set @bitN = dbo.shiftRight(@idx, @n) & 1;
            IF @even = 1 
				begin
					DECLARE @lonMid decimal(10, 7)
					SET @lonMid =  (@lonMin + @lonMax) / 2;
					IF @bitN = 1
						SET @lonMin = @lonMid;
					ELSE
						SET @lonMax = @lonMid;
				end
            ELSE
				begin
					DECLARE @latMid decimal(10, 7)
					SET @latMid =  (@latMin + @latMax) / 2;
					IF @bitN = 1
						SET @latMin = @latMid;
					ELSE
						SET @latMax = @latMid;
				end
            SET @even =  ~@even;
            SET @n = @n - 1;
		end
        SET @geohash_pos = @geohash_pos + 1;
	end

	declare @latAvg decimal(10,7)
	set @latAvg = (@latMax + @latMin) / 2

	declare @lonAvg decimal(10,7)
	set @lonAvg = (@lonMax + @lonMin) / 2
	return 'POINT(' + CONVERT(VARCHAR(30), @lonAvg) + ' ' +  CONVERT(VARCHAR(30), @latAvg) +')'
END

GO


