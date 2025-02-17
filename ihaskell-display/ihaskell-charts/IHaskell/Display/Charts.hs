module IHaskell.Display.Charts () where

import           System.Directory
import           Data.Default.Class
import           Graphics.Rendering.Chart.Renderable
import           Graphics.Rendering.Chart.Backend.Cairo
import qualified Data.ByteString.Char8 as Char
import           System.IO.Temp
import           System.IO.Unsafe

import           IHaskell.Display

width :: Width
width = 450

height :: Height
height = 300

instance IHaskellDisplay (Renderable a) where
  display renderable = do
    pngDisp <- chartData renderable PNG

    -- We can add `svg svgDisplay` to the output of `display`, but SVGs are not resizable in the IPython
    -- notebook.
    svgDisp <- chartData renderable SVG

    return $ Display [pngDisp, svgDisp]

chartData :: Renderable a -> FileFormat -> IO DisplayData
chartData renderable format = do
  withSystemTempFile "ihaskell-chart.png" $ \path _ -> do

    -- Write the PNG image.
    let opts = def { _fo_format = format, _fo_size = (width, height) }
    renderableToFile opts path renderable

    -- Convert to base64.
    imgData <- Char.readFile path
    return $
      case format of
        PNG -> png width height $ base64 imgData
        SVG -> svg $ Char.unpack imgData
