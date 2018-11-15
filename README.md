# SQL-Server-Geohash
Definition for a SQL Server scalar function that accepts a geohash and returns the latitude and longitude as a WKT Point for the center of that geohash.  Could easily be modified to get the bounding box.  

## Example:
```
SELECT dbo.decode_geohash('9q8yy')
``` 

Should return:

```POINT(-122.4096681 37.7709962)```