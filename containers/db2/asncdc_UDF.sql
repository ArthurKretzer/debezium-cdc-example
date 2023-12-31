DROP SPECIFIC FUNCTION ASNCDC.asncdcservice;

CREATE FUNCTION ASNCDC.ASNCDCSERVICES(command VARCHAR(6), service VARCHAR(8))
   RETURNS CLOB(100K)
   SPECIFIC asncdcservice
   EXTERNAL NAME 'asncdc!asncdcservice'
   LANGUAGE C
   PARAMETER STYLE SQL
   DBINFO
   DETERMINISTIC
   NOT FENCED
   RETURNS NULL ON NULL INPUT
   NO SQL
   NO EXTERNAL ACTION
   NO SCRATCHPAD
   ALLOW PARALLEL
   NO FINAL CALL;