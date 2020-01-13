//
//  ViewController.swift
//  GR_Tester
//
//  Created by Isaac Frewin on 21/03/2019.
//  Copyright © 2019 Isaac Frewin. All rights reserved.
//

import UIKit
import Charts
import Highcharts
import SwiftChart
import Foundation

//MARK: Protocol

protocol Solver {
    var r_i: Double { get }
}
// The above protocol simply says any class/struct/enum that wants to adopt me must have a property called r_i which must be a type of Double and the property must be a gettable property which was represented with { get }.


class EffectivePotential {
    
    let r_s: Double = 1.0                       //Schwarzschild radius
    let l: Double = 1*sqrt(12)                  //Specific angular momentum
    var i = 2                                   //Loop counter

    var x_at_tp = Array<Double>()               //Define array of type double
    var V_at_tp = Array<Double>()               //Define array of type double
    var x_values = Array<Double>()
    var V_values = Array<Double>()
    
    
    //MARK: Effecitve Potential
    
    //Instance to find x and V arrays
    func x_V_arrays (l: Double) -> ([Double], [Double]) {   //Function defined to return two arrays containing values of type 'Double'
        var x: Double = (r_s - 0.005)   //Initial starting position (just below Sch. radius
        
        //Equation for effective potential split into 3 parts
        let V1: Double = (-1*(r_s/(2*x)))
        let V2: Double = ((pow(l, 2))/(2*pow(x, 2)))
        let V3: Double = -1*((r_s*(pow(l, 2))/(2*pow(x, 3))))
        
        var V: Double = V1 + V2 + V3    //Combine three parts of eff. pot. eqaution
        
        var x_values = [x]  //Array to hold x values
        var V_values = [V]  //Array to hold V values
        
        while x < 100*r_s { //Max. position along axis
            V = (-1*(r_s/(2*x))) + ((pow(l, 2))/(2*pow(x, 2))) - ((r_s*(pow(l, 2))/(2*pow(x, 3))))  //Effective potential calculated for each positional argument
            x = x + (0.5*r_s)   //Move to next positional argument
            x_values.append(x)  //Append positional argument to array
            V_values.append(V)  //Append eff. pot. to array
        }
        return (x_values, V_values) //Function return arguments
    }
    
    
    /* Find turning points */
    
    func x_V_tps(x_values: [Double], V_values: [Double]) -> ([Double], [Double]) {
        while i <= ((x_values.count)-2) {   //Define loop counter
            if ((V_values[i-2] < V_values[i-1] && V_values[i] < V_values[i-1]) || (V_values[i-2] > V_values[i-1] && V_values[i] > V_values[i-1] )) {    //Compare eff. pot. minima/maximima to find if they are minimum or maximum
                //Append values to arrays
                x_at_tp.append(x_values[i-1])
                V_at_tp.append(V_values[i-1])
            }
            
            i = i + 1   //Increase loop counter value
            
        }
        
        return (x_at_tp, V_at_tp)
    }
}

//MARK: FR Solver Class

class FR_solver: Solver {

    
    /* Define Values */
    
    var effPot = EffectivePotential()   //Define variable to call EffectivePotential class
    
    let V_max: Double?                          //Max. effective potential
    let V_min: Double?                          //Min. effective potential
    let x_min: Double?                          //x-value corresponding to V_min
    let V_half_max: Double?
    let V_quart_min: Double?
    //"?" denotes that these values are optionals and could have value of nil
    
    var r_i: Double = 1                         //Manually defined initial position
    var phi_i = 0.0                             //Initial angle
    var w_i = 0.0                               //Initial angular Velocity
    var t_i = 0.0                               //Initial time
    var v_i = 0.0                               //Initial radial velocity
    let l: Double = 1*sqrt(12)                  //Specific angular momentum
    let r_s: Double = 1.0                       //Schwarzschild radius
    let theta: Double = 1/(2 - pow(2, (1/3)))   //Theta
    let c = 299792458.00                        //Speed of light
    let pi = Double.pi



    //Define empty arrays to hold later-calculated values/
    //'Array<Double>()' means define an array containing values fo type double
    //'[[Double]]()' means define multidimensional array to hold values of type double
    var radius = Array<Double>()
    var rad_vel = Array<Double>()
    var time = Array<Double>()
    var ang_vel = Array<Double>()
    var angle = Array<Double>()
    var x_y_array = [[Double]]()
    var angle_radius = [[Double]]()
    
    var x_at_tp = Array<Double>()
    var V_at_tp = Array<Double>()
    var x_values = Array<Double>()
    var V_values = Array<Double>()
    
 
    
    
    
    
    // MARK: Initialisation
    //Iinitialisation of values for later use in the program
    
    
    init() {

        self.r_i = 1
        self.w_i = l/(pow(r_i, 2))
        
        //Draw arrays from EffectivePotential class functions
        (self.x_values, self.V_values) = effPot.x_V_arrays(l: l)
        (self.x_at_tp, self.V_at_tp) = effPot.x_V_tps(x_values: x_values, V_values: V_values)
        
        //Find maximum and minimumv values in eff. pot. and positional arguments arrays
        self.V_max = V_at_tp.max()
        self.V_min  = V_at_tp.min()
        self.x_min = x_at_tp.max()
        
        //Condition to check optinal value. If 'nil' then terminate app program. If V_max nil then all optionals should be nil
        if V_max == nil {
            print("Fatal Error: V_max contains no value")
            fatalError()    //Terminate app session
        }
        
        self.V_half_max = (V_max!/2.0)
        self.V_quart_min = (V_max!/4.0)
        
        self.radius = [r_i]
        self.rad_vel = [v_i]
        self.time = [t_i]
        self.ang_vel = [w_i]
        self.angle = [phi_i]
        //self.x_y_array = [[(r_i*cos(phi_i))], [(r_i*sin(phi_i))]]
        
    }
    
    

    
    
    //MARK: Main Functions
    
    private func dvdt(r: Double) -> Double {
        return ((pow(l, 2))/(pow(r, 3))) - ((r_s)/(2*(pow(r, 2)))) - ((3*r_s*(pow(l ,2)))/(2*(pow(r, 4))))  //In c = 1 units
    }
    
    private func dphidt(r: Double) -> Double {
        return l/(pow(r, 2))
    }
    
    private func drdt(v: Double) -> Double {
        return v
    }
    
    private func dwdt(r: Double,  v: Double) -> Double {
        return ((-2*l)/(pow(r, 3)))*v
    }
    
    
    //MARK: Step-Size Optimiser
    
    //Initialise values for variables used in FR algorithm
    var r0 = 0.0; var r1 = 0.0; var r2 = 0.0; var r3 = 0.0
    var v0 = 0.0; var v1 = 0.0; var v2 = 0.0; var v3 = 0.0
    var w0 = 0.0; var w1 = 0.0; var w2 = 0.0; var w3 = 0.0
    var phi0 = 0.0; var phi1 = 0.0; var phi2 = 0.0; var phi3 = 0.0
    
    private func step(r0: Double, v0: Double, h0: Double) -> Double {
        
        /* Set up initial values */
        var h1 = h0
        var j = 1
        var error = 1.0
        var step_r = [r0]
        var err_pct = 0.0
        
        while abs(error) > 0.00001 { //Set low error target
            
            /* Run FR algorithm */
            r1 = r0 + (theta * (h1/2) * drdt(v: v0))
            v1 = v0 + (theta * h1 * dvdt(r: r1))
            r2 = r1 + ((1 - theta) * (h1/2) * drdt(v: v1))
            v2 = v1 + ((1 - (2 * theta)) * h1 * dvdt(r: r2))
            r3 = r2 + ((1 - theta) * (h1/2) * drdt(v: v2))
            v3 = v2 + (theta * h1 * dvdt(r: r3))
            
            step_r.append(r3 + (theta * (h1/2) * drdt(v: v3)))
            
            /* Modify variables for next iteration and find error */
            error = (step_r[j] - step_r[j-1])/step_r[j]
            err_pct = abs(error*100)
            h1 = h1/2.0
            j = j + 1
            
        }
        
        //print("Step size = \(h1); error = \(err_pct)%")
        
        return h1
        
    }
    
    
    //MARK: Main Algorithm
    
    func FR_algorithm(t: Double, r: Double, v: Double, phi: Double, l_fac: Double, orbit: String) -> ([Double], [Double], [[Double]]) {
        
        var k_max = ((3.49e-9)*c)   //Default setting of 1 second (coverted out of metres)
        
        
        var k = 0.0             //Initial loop counter condition
        let h0 = (k_max/2.0)    //Input step to step-size optimiser
        let h = step(r0: r, v0: v, h0: h0)  //Ouput step from step-szie optimiser
        
        /* Orbital parameters */
        r0 = r
        v0 = v
        phi0 = phi
        let l = l_fac*sqrt(12)  //Specific angular momentum - remains constant
        w0 = l/(pow(r, 2))
        var t0 = t
        
        while k <= k_max {
            
            
            /* FR to find r and v */
            
            r1 = r0 + (theta * (h/2) * drdt(v: v0))
            v1 = v0 + (theta * h * dvdt(r: r1))
            
            r2 = r1 + ((1 - theta) * (h/2) * drdt(v: v1))
            v2 = v1 + ((1 - (2 * theta)) * h * dvdt(r: r2))
            
            r3 = r2 + ((1 - theta) * (h/2) * drdt(v: v2))
            v3 = v2 + (theta * h * dvdt(r: r3))
            
            r0 = r3 + (theta * (h/2) * drdt(v: v3))
            v0 = v3
            
            
            
            /* FR to find phi and w */
            
            phi1 = phi0 + (theta * (h/2) * dphidt(r: r0))
            w1 = w0 + (theta * h * dwdt(r: r1, v: v1))
            
            phi2 = phi1 + ((1 - theta) * (h/2) * dphidt(r: r1))
            w2 = w1 + ((1 - (2 * theta)) * h * dwdt(r: r2, v: v2))
            
            phi3 = phi2 + ((1 - theta) * (h/2) * dphidt(r: r2))
            w3 = w2 + (theta * h * dwdt(r: r3, v: v3))
            
            phi0 = phi3 + (theta * (h/2) * dphidt(r: r3))
            w0 = w3
            
            /* Append results to arrays */
            radius.append(r0); time.append(t0); rad_vel.append(v0); ang_vel.append(w0); angle.append(phi0); //x_y_array[0].append(r0*cos(phi0)); x_y_array[1].append(r0*sin(phi0))
            
            //var x_axis = r0*cos(phi0)
            //var y_axis = r0*sin(phi0)
    
            x_y_array.append([r0*cos(phi0), r0*sin(phi0)])
            angle_radius.append([phi0, r0]) //Create multi-dimensional arrays
            
//            if phi0 >= 2*pi {
//                angle_radius.append([(phi0-2*pi), r0])
//            }
            
            t0 = t0 + h //Increase time by step-size
            
            if (angle.last! < (4*pi) && (k + h) >= k_max) {   //Keep running simulation if angle < 4π
                k_max = k_max + (2 * h)
            }
            
            //print(angle)
            
            /* DEBUGGING */
            if orbit == "precession" && (r0 <= 10) { print("Radius < 10") }
            //if phi0 >= (2*pi) { print("Angle > 2π") }
            //if phi0 >= (4*pi) { print("Angle > 4π") }
            
            /* Exit conditions based on orbit */
            if (orbit == "stableCircular" && angle.last! >= (2*pi)) || (orbit == "precession" && angle.last! >= (4*pi)) {
                
                //print("Final angle \(String(describing: angle_radius.last))")
                //print("First angle \(angle_radius[0])")
                angle_radius.removeLast()
                
//                if orbit == "stableCircular" {
//                    angle_radius.removeLast()
//                    angle_radius.append([2*pi, angle_radius.last![1]])
//                }
//
//                if orbit == "precession" {
//                    angle_radius.removeLast()
//                    angle_radius.append([4*pi, angle_radius.last![1]])
//                }
                
                k = k_max + 1
            }
            
            k = k + h   //Increase loop counter by step-size
            
        }
        
        return (angle, radius, angle_radius)
        
    }
}


    //MARK: Properties
    
class ViewController: UIViewController {
    
    
    // LINE CHART CODE: @IBOutlet weak var chartView: LineChartView!
    

    @IBOutlet weak var chartView: RadarChartView!   //Chart view user interface
    
    /* Define arrays/values used in later functions */
    var output = [[Double]]()
    var angle = [Double]()
    var radius = [Double]()
    var pi = Double.pi

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    @IBAction func stableCircular(_ sender: Any) {  //'Stable Circular' button in app
    
        let FR_code:FR_solver = FR_solver() //Define call index to access FR_solver class outputs

        (angle, radius, output) = FR_code.FR_algorithm(t: 0, r: 22.5, v: 0, phi: 0, l_fac: 1, orbit: "stableCircular")
        //Return FR_solver class outputs for specified input values
        
        updateGraph()   //Call UpdateGraph fucntion to plot data

    }
    
    
    @IBAction func precessionButton(_ sender: Any) {    //'Precessing Ellipse' button in app
        
        let FR_code:FR_solver = FR_solver()
        
        (angle, radius, output) = FR_code.FR_algorithm(t: 0, r: 20, v: 0, phi: 0, l_fac: 1.2, orbit: "precession")
        
        updateGraph()
        
    }
    
    
    /* Based on code from https://medium.com/@OsianSmith/creating-a-line-chart-in-swift-3-and-ios-10-2f647c95392e */

    func updateGraph() {

        /* Define empty arrays to hold ChartData for plottint */
        var radarChartEntry1 = [ChartDataEntry]()
        var radarChartEntry2 = [ChartDataEntry]()
        var radarChartEntry3 = [ChartDataEntry]()
        

        for i in 0..<(output.count) { //Count until half the total number of array elements

            //let plotValue = ChartDataEntry(x: round((1000*output[i][0]))/1000, y: round((1000*output[i][1]))/1000) //Set x and y values in data entry. Rounded as otherwsie too much data to plot - fails to display

            //DEBUGGING
            print(output[i][0])

            /* Create dataset containing angle data where 2π <= angle < 4π */
            if output[i][0] >= (2*pi) && output[i][0] < (4*pi) {
                let plotValue = ChartDataEntry(x: ((output[i][0]) - 2*pi), y: output[i][1])
                
                //DEBUGGING
                if output[i][1] < 5 { print("radius < 5 in radarChartEntry2 at \(i)") }
                
                radarChartEntry2.append(plotValue)
                //print("Second DataSet Created") //Debug message
            }

            /* Create dataset containing angle data where angle => 4π */
            else if output[i][0] >= (4*pi) {
                let plotValue = ChartDataEntry(x: ((output[i][0]) - 4*pi), y: output[i][1])
                
                //DEBUGGING
                if output[i][1] < 5 { print("radius < 5 in radarChartEntry3 at \(i)") }
                
                radarChartEntry3.append(plotValue)
            }

            /* Create dataset containing angle data where angle < 2π */
            else {
                let plotValue = ChartDataEntry(x: output[i][0], y: output[i][1])
                
                //DEBUGGING
                if output[i][1] < 5 { print("radius < 5 in radarChartEntry1 at \(i)") }
                
                radarChartEntry1.append(plotValue)  //Add value to dataset
            }

            //DEBUGGING
            //print(radarChartEntry1, radarChartEntry2, radarChartEntry3)

        }

        /* Create constants containing linechart data */
        let radarPlot1 = RadarChartDataSet(values: radarChartEntry1, label: "") //Convert lineDataEntry LineChartDataSet
        let radarPlot2 = RadarChartDataSet(values: radarChartEntry2, label: "") //Convert lineDataEntry LineChartDataSet
        let radarPlot3 = RadarChartDataSet(values: radarChartEntry3, label: "") //Convert lineDataEntry LineChartDataSet

        /* Set line colour */
        radarPlot1.colors = [NSUIColor.red]
        radarPlot2.colors = [NSUIColor.blue]
        radarPlot3.colors = [NSUIColor.red]

        /* Remove highlighted point markers */
        radarPlot1.drawValuesEnabled = false
        radarPlot2.drawValuesEnabled = false
        radarPlot3.drawValuesEnabled = false

        let data = RadarChartData()  //Object that will be added to chart

        /* Add line to dataset */
        data.addDataSet(radarPlot1)
        data.addDataSet(radarPlot2)
        data.addDataSet(radarPlot3)

        chartView.data = data   //Add data to chart and cause update

        /* Set plot area constraints */
        chartView.yAxis.axisMinimum = /*radius.min() ??*/ 0
        chartView.xAxis.drawLabelsEnabled = false
        chartView.webColor = NSUIColor.white
        chartView.innerWebColor = NSUIColor.gray
        chartView.chartDescription?.text = "Orbit" //Graph title

    }
}
