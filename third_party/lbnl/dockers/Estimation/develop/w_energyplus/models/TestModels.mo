within ;
package TestModels

  package MPC

    model R1C1 "Reduced order zone model with no heating and cooling inputs"
      parameter Modelica.SIunits.ThermalResistance R=0.01 "Resistance of zone";
      parameter Modelica.SIunits.HeatCapacity C=1e5 "Capacitance of zone";
      parameter Real shgc=0.8 "Solar heat gain coefficient of window";
      parameter Modelica.SIunits.Temperature T0=5 + 273.15
        "Initial temperature of C";

      Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor senTemp
        "Temperature sensor"
        annotation (Placement(transformation(extent={{60,-10},{80,10}})));
      Modelica.Thermal.HeatTransfer.Components.HeatCapacitor air(C=C, T(start=
              T0, fixed=true))
        annotation (Placement(transformation(extent={{30,0},{50,20}})));
      Modelica.Thermal.HeatTransfer.Components.ThermalResistor tR(R=R)
        annotation (Placement(transformation(extent={{-18,-10},{2,10}})));
      Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature preTem
        annotation (Placement(transformation(extent={{-58,-10},{-38,10}})));
      Modelica.Blocks.Math.Gain gain(k=shgc)
        annotation (Placement(transformation(extent={{-56,50},{-36,70}})));
      Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow phf1
        annotation (Placement(transformation(extent={{-14,50},{6,70}})));
      Modelica.Blocks.Interfaces.RealOutput Tzone(unit="K")
        "Zone mean air drybulb temperature" annotation (Placement(
            transformation(extent={{100,-10},{120,10}}), iconTransformation(
              extent={{100,-10},{120,10}})));
      Modelica.Blocks.Interfaces.RealInput weaTDryBul(unit="K")
        annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));
      Modelica.Blocks.Interfaces.RealInput weaHGloHor(unit="W/m2")
        annotation (Placement(transformation(extent={{-140,40},{-100,80}})));
    equation

      connect(senTemp.T, Tzone)
        annotation (Line(points={{80,0},{110,0}}, color={0,0,127}));
      connect(tR.port_b, air.port)
        annotation (Line(points={{2,0},{40,0}}, color={191,0,0}));
      connect(senTemp.port, air.port)
        annotation (Line(points={{60,0},{40,0}}, color={191,0,0}));
      connect(gain.y, phf1.Q_flow)
        annotation (Line(points={{-35,60},{-14,60}}, color={0,0,127}));
      connect(phf1.port, air.port) annotation (Line(points={{6,60},{20,60},{20,
              0},{40,0}}, color={191,0,0}));
      connect(preTem.T, weaTDryBul)
        annotation (Line(points={{-60,0},{-120,0}}, color={0,0,127}));
      connect(weaHGloHor, gain.u)
        annotation (Line(points={{-120,60},{-58,60}}, color={0,0,127}));
      connect(preTem.port, tR.port_a)
        annotation (Line(points={{-38,0},{-18,0}}, color={191,0,0}));
      annotation (
        experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          __Dymola_Algorithm="Radau"),
        Documentation(info="<html>
<p>
This model an RC model with 1R and 1C.
</p>
</html>", revisions="<html>
<ul>
<li>
October 6, xxx, by xxx:<br/>
First implementation.
</li>
</ul>
</html>"),
        Icon(graphics={
            Rectangle(
              extent={{-92,92},{92,-92}},
              pattern=LinePattern.None,
              lineColor={117,148,176},
              fillColor={170,213,255},
              fillPattern=FillPattern.Sphere),
            Rectangle(
              extent={{-100,-100},{100,100}},
              lineColor={95,95,95},
              fillColor={95,95,95},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{-92,92},{92,-92}},
              pattern=LinePattern.None,
              lineColor={117,148,176},
              fillColor={170,213,255},
              fillPattern=FillPattern.Sphere),
            Rectangle(
              extent={{-44,42},{54,-46}},
              lineColor={0,0,0},
              fillColor={135,135,135},
              fillPattern=FillPattern.Solid),
            Text(
              extent={{-150,144},{150,104}},
              textString="%name",
              lineColor={0,0,255})}),
        __Dymola_experimentSetupOutput(events=false));
    end R1C1;

    model R1C1HeatCool
      "Reduced order zone model with heating and cooling inputs"
      extends R1C1(weaTDryBul(unit="K"), weaHGloHor(unit="W/m2"));
      Modelica.Blocks.Interfaces.RealInput QHeaCoo(unit="W")
        annotation (Placement(transformation(extent={{-140,-80},{-100,-40}})));
      Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow preHeaCoo
        annotation (Placement(transformation(extent={{-36,-70},{-16,-50}})));
    equation
      connect(QHeaCoo, preHeaCoo.Q_flow)
        annotation (Line(points={{-120,-60},{-36,-60}}, color={0,0,127}));
      connect(preHeaCoo.port, air.port) annotation (Line(points={{-16,-60},{20,
              -60},{20,0},{40,0}}, color={191,0,0}));
      annotation (Documentation(info="<html>
<p>
This model an RC model with 1R and 1C with an 
additional input for the HVAC.
</p>
</html>"));
    end R1C1HeatCool;

    model R2C2 "Reduced order zone model with no heating and cooling inputs"
      parameter Modelica.SIunits.ThermalResistance R=0.01 "Resistance of zone";
      parameter Modelica.SIunits.ThermalResistance Ri=0.01
        "Resistance of internal thermal mass";
      parameter Modelica.SIunits.HeatCapacity C=1e5 "Capacitance of zone";
      parameter Modelica.SIunits.HeatCapacity Ci=1e5
        "Capacitance of internal thermal mass";
      parameter Real shgc=0.8 "Solar heat gain coefficient of window";
      parameter Modelica.SIunits.Temperature T0=5 + 273.15
        "Initial temperature of all C";

      Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor senTem
        annotation (Placement(transformation(extent={{62,-10},{82,10}})));
      Modelica.Thermal.HeatTransfer.Components.HeatCapacitor air(C=C, T(start=T0,
            fixed=true))
        annotation (Placement(transformation(extent={{42,0},{62,20}})));
      Modelica.Thermal.HeatTransfer.Components.ThermalResistor tR(R=R)
        annotation (Placement(transformation(extent={{-2,-10},{18,10}})));
      Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature preTem
        annotation (Placement(transformation(extent={{-58,-10},{-38,10}})));
      Modelica.Blocks.Math.Gain gain(k=shgc)
        annotation (Placement(transformation(extent={{-22,50},{-2,70}})));
      Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow phf1
        annotation (Placement(transformation(extent={{8,50},{28,70}})));
      Modelica.Blocks.Interfaces.RealOutput Tzone(unit="K")
        "Zone mean air drybulb temperature" annotation (Placement(transformation(
              extent={{100,-10},{120,10}}), iconTransformation(extent={{100,-10},{120,
                10}})));
      Modelica.Blocks.Interfaces.RealInput weaTDryBul(unit="K")
        annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));
      Modelica.Blocks.Interfaces.RealInput weaHGloHor(unit="W/m2")
        annotation (Placement(transformation(extent={{-140,40},{-100,80}})));
      Modelica.Thermal.HeatTransfer.Components.HeatCapacitor intMass(C=Ci, T(start=
              T0, fixed=true))
        annotation (Placement(transformation(extent={{30,60},{50,80}})));
      Modelica.Thermal.HeatTransfer.Components.ThermalResistor tRi(R=Ri)
        annotation (Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=0,
            origin={20,30})));
    equation

      connect(senTem.T, Tzone)
        annotation (Line(points={{82,0},{110,0}}, color={0,0,127}));
      connect(tR.port_b, air.port)
        annotation (Line(points={{18,0},{52,0}}, color={191,0,0}));
      connect(senTem.port, air.port)
        annotation (Line(points={{62,0},{52,0}}, color={191,0,0}));
      connect(preTem.port, tR.port_a)
        annotation (Line(points={{-38,0},{-2,0}}, color={191,0,0}));
      connect(gain.y, phf1.Q_flow)
        annotation (Line(points={{-1,60},{8,60}}, color={0,0,127}));
      connect(weaHGloHor, gain.u)
        annotation (Line(points={{-120,60},{-24,60}}, color={0,0,127}));
      connect(phf1.port, intMass.port)
        annotation (Line(points={{28,60},{40,60}}, color={191,0,0}));
      connect(intMass.port, tRi.port_a) annotation (Line(points={{40,60},{40,50},{0,
              50},{0,30},{10,30}}, color={191,0,0}));
      connect(tRi.port_b, air.port)
        annotation (Line(points={{30,30},{34,30},{34,0},{52,0}}, color={191,0,0}));
      connect(preTem.T, weaTDryBul)
        annotation (Line(points={{-60,0},{-120,0}}, color={0,0,127}));
      annotation (
        experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          __Dymola_Algorithm="Radau"),
        __Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/ThermalZones/Detailed/Validation/BESTEST/Case600FF.mos"
            "Simulate and plot"),
        Documentation(info="<html>
<p>
<p>
This model an RC model with 2R and 2C.
</p>
</p>
</html>",     revisions="<html>
<ul>
<li>
October 29, 2016, by Michael Wetter:<br/>
Placed a capacity at the room-facing surface
to reduce the dimension of the nonlinear system of equations,
which generally decreases computing time.<br/>
Removed the pressure drop element which is not needed.<br/>
Linearized the radiative heat transfer, which is the default in
the library, and avoids a large nonlinear system of equations.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/565\">issue 565</a>.
</li>
<li>
December 22, 2014 by Michael Wetter:<br/>
Removed <code>Modelica.Fluid.System</code>
to address issue
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/311\">#311</a>.
</li>
<li>
October 9, 2013, by Michael Wetter:<br/>
Implemented soil properties using a record so that <code>TSol</code> and
<code>TLiq</code> are assigned.
This avoids an error when the model is checked in the pedantic mode.
</li>
<li>
July 15, 2012, by Michael Wetter:<br/>
Added reference results.
Changed implementation to make this model the base class
for all BESTEST cases.
Added computation of hourly and annual averaged room air temperature.
<li>
October 6, 2011, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"),
        Icon(graphics={
            Rectangle(
              extent={{-92,92},{92,-92}},
              pattern=LinePattern.None,
              lineColor={117,148,176},
              fillColor={170,213,255},
              fillPattern=FillPattern.Sphere),
            Rectangle(
              extent={{-100,-100},{100,100}},
              lineColor={95,95,95},
              fillColor={95,95,95},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{-92,92},{92,-92}},
              pattern=LinePattern.None,
              lineColor={117,148,176},
              fillColor={170,213,255},
              fillPattern=FillPattern.Sphere),
            Rectangle(
              extent={{-44,42},{54,-46}},
              lineColor={0,0,0},
              fillColor={135,135,135},
              fillPattern=FillPattern.Solid),
            Text(
              extent={{-150,144},{150,104}},
              textString="%name",
              lineColor={0,0,255})}),
        __Dymola_experimentSetupOutput(events=false));
    end R2C2;

    model R2C2HeatCool
      "Reduced order zone model with heating and cooling inputs"
      extends R2C2(weaHGloHor(unit="W/m2"), weaTDryBul(unit="K"));
      Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow preHeaCoo
        annotation (Placement(transformation(extent={{-18,-70},{2,-50}})));
      Modelica.Blocks.Interfaces.RealInput QHeaCoo(unit="W")
        annotation (Placement(transformation(extent={{-140,-80},{-100,-40}})));
    equation
      connect(QHeaCoo, preHeaCoo.Q_flow)
        annotation (Line(points={{-120,-60},{-18,-60}}, color={0,0,127}));
      connect(preHeaCoo.port, air.port) annotation (Line(points={{2,-60},{34,
              -60},{34,0},{52,0}}, color={191,0,0}));
      annotation (Documentation(info="<html>
<p>
This model an RC model with 2R and 2C with an 
additional input for the HVAC.
</p>
</html>"));
    end R2C2HeatCool;

    model R3C3 "Reduced order zone model with no heating and cooling inputs"
      parameter Modelica.SIunits.ThermalResistance R=0.01 "Resistance of zone";
      parameter Modelica.SIunits.ThermalResistance Ri=0.01
        "Resistance of internal thermal mass";
      parameter Modelica.SIunits.ThermalResistance Re=0.01
        "Resistance of external thermal mass";
      parameter Modelica.SIunits.HeatCapacity C=1e5 "Capacitance of zone";
      parameter Modelica.SIunits.HeatCapacity Ci=1e5
        "Capacitance of internal thermal mass";
      parameter Modelica.SIunits.HeatCapacity Ce=1e5
        "Capacitance of external thermal mass";
      parameter Real shgc=0.8 "Solar heat gain coefficient of window";
      parameter Real shgce=0.8 "Solar heat gain coefficient of ext. walls";
      parameter Modelica.SIunits.Temperature T0=5 + 273.15
        "Initial temperature of all C";

      Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor senTem
        annotation (Placement(transformation(extent={{66,-10},{86,10}})));
      Modelica.Thermal.HeatTransfer.Components.HeatCapacitor air(C=C, T(start=T0,
            fixed=true))
        annotation (Placement(transformation(extent={{42,0},{62,20}})));
      Modelica.Thermal.HeatTransfer.Components.ThermalResistor tRe(R=Re)
        annotation (Placement(transformation(extent={{-50,10},{-30,30}})));
      Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature
        prescribedTemperature
        annotation (Placement(transformation(extent={{-82,10},{-62,30}})));
      Modelica.Blocks.Math.Gain gain(k=shgc)
        annotation (Placement(transformation(extent={{-15,53},{-1,67}})));
      Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow phf1
        annotation (Placement(transformation(extent={{14,54},{26,66}})));
      Modelica.Blocks.Interfaces.RealOutput Tzone(unit="K")
        "Zone mean air drybulb temperature" annotation (Placement(transformation(
              extent={{100,-10},{120,10}}), iconTransformation(extent={{100,-10},{120,
                10}})));
      Modelica.Blocks.Interfaces.RealInput weaTDryBul(unit="K")
        annotation (Placement(transformation(extent={{-140,0},{-100,40}})));
      Modelica.Blocks.Interfaces.RealInput weaHGloHor(unit="W/m2")
        annotation (Placement(transformation(extent={{-140,-80},{-100,-40}})));
      Modelica.Thermal.HeatTransfer.Components.HeatCapacitor intMass(C=Ci, T(start=
              T0, fixed=true))
        annotation (Placement(transformation(extent={{32,60},{52,80}})));
      Modelica.Thermal.HeatTransfer.Components.ThermalResistor tRi(R=Ri)
        annotation (Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=0,
            origin={20,30})));
      Modelica.Thermal.HeatTransfer.Components.ThermalResistor tR(R=R)
        annotation (Placement(transformation(extent={{10,-50},{30,-30}})));
      Modelica.Thermal.HeatTransfer.Components.HeatCapacitor extMass(C=Ce, T(start=
              T0, fixed=true))
        annotation (Placement(transformation(extent={{-20,-40},{0,-20}})));
      Modelica.Blocks.Math.Gain gain6(k=shgce)
        annotation (Placement(transformation(extent={{-83,-67},{-69,-53}})));
      Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow phf5 annotation (
          Placement(transformation(
            extent={{-6,-6},{6,6}},
            rotation=90,
            origin={-10,-54})));
    equation

      connect(senTem.T, Tzone)
        annotation (Line(points={{86,0},{110,0}}, color={0,0,127}));
      connect(senTem.port, air.port)
        annotation (Line(points={{66,0},{52,0}}, color={191,0,0}));
      connect(prescribedTemperature.port, tRe.port_a)
        annotation (Line(points={{-62,20},{-50,20}}, color={191,0,0}));
      connect(gain.y, phf1.Q_flow)
        annotation (Line(points={{-0.3,60},{-0.3,60},{14,60}}, color={0,0,127}));
      connect(prescribedTemperature.T, weaTDryBul)
        annotation (Line(points={{-84,20},{-120,20}}, color={0,0,127}));
      connect(phf1.port, intMass.port)
        annotation (Line(points={{26,60},{26,60},{42,60}}, color={191,0,0}));
      connect(intMass.port, tRi.port_a) annotation (Line(points={{42,60},{42,50},{2,
              50},{2,30},{10,30}}, color={191,0,0}));
      connect(tRi.port_b, air.port)
        annotation (Line(points={{30,30},{34,30},{34,0},{52,0}}, color={191,0,0}));
      connect(air.port, tR.port_b) annotation (Line(points={{52,0},{34,0},{34,-40},{
              30,-40}}, color={191,0,0}));
      connect(tRe.port_b, extMass.port) annotation (Line(points={{-30,20},{-26,20},{
              -26,-40},{-10,-40}}, color={191,0,0}));
      connect(tR.port_a, extMass.port)
        annotation (Line(points={{10,-40},{-10,-40}}, color={191,0,0}));
      connect(gain6.y, phf5.Q_flow)
        annotation (Line(points={{-68.3,-60},{-10,-60}}, color={0,0,127}));
      connect(gain6.u, weaHGloHor)
        annotation (Line(points={{-84.4,-60},{-120,-60}}, color={0,0,127}));
      connect(phf5.port, extMass.port)
        annotation (Line(points={{-10,-48},{-10,-44},{-10,-40}}, color={191,0,0}));
      connect(gain.u, weaHGloHor) annotation (Line(points={{-16.4,60},{-22,60},{-22,
              -20},{-100,-20},{-100,-60},{-120,-60}}, color={0,0,127}));
      annotation (
        experiment(
          StopTime=3.1536e+07,
          Interval=3600,
          __Dymola_Algorithm="Radau"),
        __Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/ThermalZones/Detailed/Validation/BESTEST/Case600FF.mos"
            "Simulate and plot"),
        Documentation(info="<html>
<p>
This model an RC model with 3R and 3C.
</p>
</html>",     revisions="<html>
<ul>
<li>
October 29, 2016, by Michael Wetter:<br/>
Placed a capacity at the room-facing surface
to reduce the dimension of the nonlinear system of equations,
which generally decreases computing time.<br/>
Removed the pressure drop element which is not needed.<br/>
Linearized the radiative heat transfer, which is the default in
the library, and avoids a large nonlinear system of equations.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/565\">issue 565</a>.
</li>
<li>
December 22, 2014 by Michael Wetter:<br/>
Removed <code>Modelica.Fluid.System</code>
to address issue
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/311\">#311</a>.
</li>
<li>
October 9, 2013, by Michael Wetter:<br/>
Implemented soil properties using a record so that <code>TSol</code> and
<code>TLiq</code> are assigned.
This avoids an error when the model is checked in the pedantic mode.
</li>
<li>
July 15, 2012, by Michael Wetter:<br/>
Added reference results.
Changed implementation to make this model the base class
for all BESTEST cases.
Added computation of hourly and annual averaged room air temperature.
<li>
October 6, 2011, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"),
        Icon(graphics={
            Rectangle(
              extent={{-92,92},{92,-92}},
              pattern=LinePattern.None,
              lineColor={117,148,176},
              fillColor={170,213,255},
              fillPattern=FillPattern.Sphere),
            Rectangle(
              extent={{-100,-100},{100,100}},
              lineColor={95,95,95},
              fillColor={95,95,95},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{-92,92},{92,-92}},
              pattern=LinePattern.None,
              lineColor={117,148,176},
              fillColor={170,213,255},
              fillPattern=FillPattern.Sphere),
            Rectangle(
              extent={{-44,42},{54,-46}},
              lineColor={0,0,0},
              fillColor={135,135,135},
              fillPattern=FillPattern.Solid),
            Text(
              extent={{-150,144},{150,104}},
              textString="%name",
              lineColor={0,0,255})}),
        __Dymola_experimentSetupOutput(events=false));
    end R3C3;

    model R3C3HeatCool
      "Reduced order zone model with heating and cooling inputs"
      extends R3C3(weaTDryBul(unit="K"), weaHGloHor(unit="W"));
      Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow preHeaCoo
        annotation (Placement(transformation(extent={{6,-100},{26,-80}})));
      Modelica.Blocks.Interfaces.RealInput QHeaCoo(unit="W")
        annotation (Placement(transformation(extent={{-140,-110},{-100,-70}})));
    equation
      connect(QHeaCoo, preHeaCoo.Q_flow)
        annotation (Line(points={{-120,-90},{6,-90}}, color={0,0,127}));
      connect(preHeaCoo.port, air.port)
        annotation (Line(points={{26,-90},{52,-90},{52,0}}, color={191,0,0}));
      annotation (Documentation(info="<html>
<p>
This model an RC model with 3R and 3C with 
an additional input for the HVAC.
</p>
</html>"));
    end R3C3HeatCool;

  end MPC;

end TestModels;
