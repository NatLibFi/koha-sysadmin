import Data.Marc21
import qualified Data.ByteString.Char8 as C

main :: IO ()
main = do
    fccSF <- readFile "melinda-ids_fikka-biblionumbers"
    let fccs = fccReader fccSF
    recCF <- C.readFile "fikka-records-to-FCCify.mrc"
    let records = marcReader recCF
    let updrecs = map (addFCC fccs) records
    C.putStr $ marcWriter updrecs

fccReader :: String -> [(String, String)]
fccReader sFile = map ((\[fcc, bno] -> (bno, fcc)) . words) (lines sFile)

addFCC :: [(String, String)] -> Record -> Record
addFCC fccs r = r {fields = prefields ++ newfield : postfields}
   where Just fcc = lookup (getBiblionumber r) fccs
         [fno, sfc, val] = map C.pack ["035", "a", "FCC" ++ fcc]
         (prefields, postfields) = span (\f -> tag f <= fno) (fields r)
         newfield = VarField fno ' ' ' ' [(sfc, val)]

getBiblionumber :: Record -> String
getBiblionumber r = C.unpack bno
    where [bno] = getSubFieldValueList (["999"], "c") r
