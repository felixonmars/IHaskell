{- There are 3 types of plots to consider in haskell-gnuplot: Plot, Frame and Multiplot.
   Plot types are the actual plots, whereas Frame types are plots with additional options
   e.g. custom axes tics, graph title etc.. Multiplots are collections of 2D and/or 3D plots.
   We have to create instances of IHaskellDisplay for all of these types.

   Note: To stop gnuplot from printing the filepath ontop of the canvas, you have to set
         the gnuplot option "key" to "noautotitle".
         Code: Graphics.Gnuplot.Frame.cons (Graphics.Gnuplot.Frame.OptionSet.add
                                                    (Graphics.Gnuplot.Frame.Option.key "")
                                                    ["noautotitle"] $ ...)
-}
module IHaskell.Display.Gnuplot where

import qualified Graphics.Gnuplot.Plot as P
import qualified Graphics.Gnuplot.Frame as F
import qualified Graphics.Gnuplot.MultiPlot as M
import qualified Graphics.Gnuplot.Terminal.PNG as Pn
import qualified Graphics.Gnuplot.Terminal.SVG as Sv
import qualified Graphics.Gnuplot.Display as D
import qualified Graphics.Gnuplot.Graph as G
import qualified Data.ByteString.Char8 as Char
import           System.IO.Temp
import           Graphics.Gnuplot.Advanced (plot)
import           IHaskell.Display

-- Plot-types
instance G.C graph => IHaskellDisplay (P.T graph) where
  display = graphDataDisplayBoth

-- Frame-types
instance G.C graph => IHaskellDisplay (F.T graph) where
  display = graphDataDisplayBoth

-- Type: Multiplot
instance IHaskellDisplay M.T where
  display = graphDataDisplayBoth

-- Width and height
w = 300

h = 300

graphDataPNG :: D.C gfx => gfx -> IO DisplayData
graphDataPNG graph = do
  withSystemTempFile "ihaskell-gnuplot.png" $ \path _ -> do

    -- Write the image.
    plot (Pn.cons path) graph

    -- Read back, and convert to base64.
    imgData <- Char.readFile path
    return $ png w h $ base64 imgData

graphDataSVG :: D.C gfx => gfx -> IO DisplayData
graphDataSVG graph = do
  withSystemTempFile "ihaskell-gnuplot.svg" $ \path _ -> do

    -- Write the image.
    plot (Sv.cons path) graph

    -- Read back, and convert to base64.
    imgData <- Char.readFile path
    return $ svg $ Char.unpack imgData

graphDataDisplayBoth :: D.C gfx => gfx -> IO Display
graphDataDisplayBoth fig = do
    pngDisp <- graphDataPNG fig
    svgDisp <- graphDataSVG fig
    return $ Display [pngDisp, svgDisp]
