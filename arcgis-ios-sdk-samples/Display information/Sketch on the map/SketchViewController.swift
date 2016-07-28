// Copyright 2016 Esri.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import ArcGIS

class SketchViewController: UIViewController {

    @IBOutlet private weak var mapView:AGSMapView!
    @IBOutlet private weak var geometrySegmentedControl:UISegmentedControl!
    @IBOutlet private weak var undoBBI:UIBarButtonItem!
    @IBOutlet private weak var redoBBI:UIBarButtonItem!
    @IBOutlet private weak var clearBBI:UIBarButtonItem!
    
    
    private var map:AGSMap!
    private var sketchGraphicsOverlay:AGSSketchGraphicsOverlay!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add the source code button item to the right of navigation bar
        (self.navigationItem.rightBarButtonItem as! SourceCodeBarButtonItem).filenames = ["SketchViewController"]
        
        self.map = AGSMap(basemap: AGSBasemap.lightGrayCanvasBasemap())
        
        self.sketchGraphicsOverlay = AGSSketchGraphicsOverlay()
        self.sketchGraphicsOverlay.geometryBuilder = AGSPolylineBuilder(spatialReference: AGSSpatialReference.webMercator())
        self.mapView.graphicsOverlays.addObject(self.sketchGraphicsOverlay)
        
        self.mapView.touchDelegate = self.sketchGraphicsOverlay
        
        self.mapView.map = self.map
        self.mapView.magnifierEnabled = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SketchViewController.respondToGeomChanged), name: AGSSketchGraphicsOverlayGeometryDidChangeNotification, object: nil)

        //set initial viewpoint
        self.map.initialViewpoint = AGSViewpoint(targetExtent: AGSEnvelope(XMin: -10049589.670344, yMin: 3480099.843772, xMax: -10010071.251113, yMax: 3512023.489701, spatialReference: AGSSpatialReference.webMercator()))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func respondToGeomChanged() {
        //Enable/disable UI elements appropriately
        self.undoBBI.enabled = self.sketchGraphicsOverlay.undoManager.canUndo
        self.redoBBI.enabled = self.sketchGraphicsOverlay.undoManager.canRedo
        self.clearBBI.enabled = self.sketchGraphicsOverlay.geometryBuilder != nil && !self.sketchGraphicsOverlay.geometryBuilder!.isEmpty()
    }
    
    //MARK: - Actions
    
    @IBAction func geometryValueChanged(segmentedControl:UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0://point
            self.sketchGraphicsOverlay.geometryBuilder = AGSPointBuilder(spatialReference: AGSSpatialReference.webMercator())
            
        case 1://polyline
            self.sketchGraphicsOverlay.geometryBuilder = AGSPolylineBuilder(spatialReference: AGSSpatialReference.webMercator())
            
        case 2://polygon
            self.sketchGraphicsOverlay.geometryBuilder = AGSPolygonBuilder(spatialReference: AGSSpatialReference.webMercator())
            
        default:
            break
        }
        self.sketchGraphicsOverlay.undoManager.removeAllActions()
    }
    
    @IBAction func undo() {
        if self.sketchGraphicsOverlay.undoManager.canUndo { //extra check, just to be sure
            self.sketchGraphicsOverlay.undoManager.undo()
        }
    }
    
    @IBAction func redo() {
        if self.sketchGraphicsOverlay.undoManager.canRedo { //extra check, just to be sure
            self.sketchGraphicsOverlay.undoManager.redo()
        }
    }
    
    @IBAction func clear() {
        self.sketchGraphicsOverlay.clear()
    }
}