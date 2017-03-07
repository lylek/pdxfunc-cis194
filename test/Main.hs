{-# LANGUAGE TupleSections #-}
module Main(main) where

import Week1

import qualified Data.Map as M
import qualified Data.Set as S
import Test.Tasty
import Test.Tasty.HUnit
import Test.Tasty.QuickCheck

main :: IO ()
main = defaultMain $ testGroup "tests" [luhns, hanoiTests]

luhns :: TestTree
luhns = testGroup "Credit card number validation"
  [ testGroup "valid" $ map (testCCNumber True) validCCs,
    testGroup "invalid" $ map (testCCNumber False) invalidCCs
  ]

testCCNumber :: Bool -> Integer -> TestTree
testCCNumber shouldBe ccNum = testCase (show ccNum) $ assertBool msg good
  where
  good = validateCC ccNum == shouldBe
  msg = if shouldBe
    then "validateCC should've returned True but returned False"
    else "validateCC should've returned False but returned True"

validCCs :: [Integer]
validCCs = [4161432561375371,
            4149109264359442,
            4730337425648024,
            4068980297925194,
            4387683432204,
            364863961308302,
            360205910934594,
            6011108144784134,
            6011910316770969,
            6011141212296400]

invalidCCs :: [Integer]
invalidCCs = [1817288007626273,
              4123618622277941,
              7431095047062952,
              487382095888311,
              8818474798706813,
              1201986593695480,
              6982679871091527,
              3300261759248522,
              4911184023267466,
              2418104020069560]

hanoiTests :: TestTree
hanoiTests = testGroup "Towers of Hanoi"
  [testProperty "3 pegs (QuickCheck)" $ \(Positive n) src tgt tmp ->
      let pegs = [src, tgt, tmp] in
      n < 7 && uniqueList pegs ==>
      validateHanoi n pegs $ hanoi n src tgt tmp,
   testProperty "4 pegs (QuickCheck)" $ \(Positive n) src tgt tmp1 tmp2 ->
      let pegs = [src, tgt, tmp1, tmp2] in
      n < 7 && uniqueList pegs ==>
      validateHanoi n pegs $ hanoi2 n src tgt tmp1 tmp2
  ]

validateHanoi :: Integer -> [Peg] -> [Move] -> Bool
validateHanoi _ [] _ = error "validateHanoi called with zero pegs"
validateHanoi _ [_] _ = error "validateHanoi called with only one peg"
validateHanoi 0 _ moves = moves == []
validateHanoi n (srcPeg : tgtPeg : otherPegs) moves =
  go moves $ M.fromList $ (srcPeg, [0 .. n - 1]) : map (, []) (tgtPeg : otherPegs)
  where
  go :: [Move] -> M.Map Peg [Integer] -> Bool
  go [] pegState = pegState == M.fromList
    ([(srcPeg, []), (tgtPeg, [0 .. n - 1])] ++ map (, []) otherPegs)
  go ((moveSrc, moveDest) : movesRest) pegState =
    case (M.lookup moveSrc pegState, M.lookup moveDest pegState) of
      (Just (srcTop : srcRest), Just destDisks) ->
        if smallerThanTop srcTop destDisks
        then let newState = M.insert moveDest (srcTop : destDisks) $
                   M.insert moveSrc srcRest pegState in
          go movesRest newState
        else False
      _                               -> False

uniqueList :: (Eq a, Ord a) => [a] -> Bool
uniqueList xs = go xs S.empty
  where
  go []       _   = True
  go (y : ys) set = not (S.member y set) && go ys (S.insert y set)

smallerThanTop :: Integer -> [Integer] -> Bool
smallerThanTop _ []        = True
smallerThanTop n (x : _xs) = n < x
