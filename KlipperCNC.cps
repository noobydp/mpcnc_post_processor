/// <reference path="c:\Users\david\.vscode\extensions\autodesk.hsm-post-processor-4.1.6\res\language files\globals.d.ts" />
/*

https://cam.autodesk.com/posts/posts/guides/Post%20Processor%20Training%20Guide.pdf
https://cam.autodesk.com/posts/reference/classPostProcessor.html
*/

description = 'Milling/Laser';
vendor = 'noobydp';
vendorUrl = 'https://github.com/noobydp/mpcnc_post_processor';

// Internal properties
certificationLevel = 2;
extension = 'gcode';
setCodePage('ascii');
capabilities = CAPABILITY_MILLING | CAPABILITY_JET;

machineMode = undefined; //TYPE_MILLING, TYPE_JET

var eFirmware = {
  KLIPPER: 2,
  KLIPPERCNC: 1,
  prop: {
    1: { name: 'Klipper CNC Fork', value: 1 },
    2: { name: 'Klipper', value: 2 }
  }
};

var fw = eFirmware.KLIPPER;

var eComment = {
  Off: 0,
  Important: 1,
  Info: 2,
  Debug: 3,
  prop: {
    0: { name: 'Off', value: 0 },
    1: { name: 'Important', value: 1 },
    2: { name: 'Info', value: 2 },
    3: { name: 'Debug', value: 3 }
  }
};

var eCoolant = {
  Off: 0,
  Flood: 1,
  Mist: 2,
  ThroughTool: 3,
  Air: 4,
  AirThroughTool: 5,
  Suction: 6,
  FloodMist: 7,
  FloodThroughTool: 8,
  prop: {
    0: { name: 'Off', value: 0 },
    1: { name: 'Flood', value: 1 },
    2: { name: 'Mist', value: 2 },
    3: { name: 'ThroughTool', value: 3 },
    4: { name: 'Air', value: 4 },
    5: { name: 'AirThroughTool', value: 5 },
    6: { name: 'Suction', value: 6 },
    7: { name: 'Flood and Mist', value: 7 },
    8: { name: 'Flood and ThroughTool', value: 8 }
  }
};

var groupDefinitions = {
	hardware: { title: 'Hardware', collapsed: false, order: 1 },
  job: { title: 'Job', description: 'Job', collapsed: false, order: 10 },
  jobMacros: { title: 'Macros', collapsed: false, order: 11 },
  jobSequence: { title: 'Sequence', collapsed: true, order: 12 },
  framing: {
    title: 'Framing',
    collapsed: false,
    order: 20
  },
  speeds: { title: 'Speeds', collapsed: false, order: 30 },
  rapidMoves: { title: 'Rapid Moves', collapsed: false, order: 40 },
  toolChanger: { title: 'Tool Changer', collapsed: true, order: 50 },
  probing: { title: 'Probing', collapsed: false, order: 60 },
  laser: { title: 'Laser', collapsed: true, order: 70 },
  coolant: { title: 'Coolant', collapsed: false, order: 80 },
  externalFiles: { title: 'External Files', collapsed: false, order: 90 }
  // Job: {title: "Job", collapsed: false, order: 10},
};

var properties = {
  controllerFirmware: {
    title: 'CNC Firmware',
    description: 'Dialect of GCode to create',
    group: 'hardware',
    type: 'integer',
    default_mm: eFirmware.KLIPPER,
    default_in: eFirmware.KLIPPER,
    values: [
      { title: eFirmware.prop[eFirmware.KLIPPER].name, id: eFirmware.KLIPPER },
      {
        title: eFirmware.prop[eFirmware.KLIPPERCNC].name,
        id: eFirmware.KLIPPERCNC
      }
    ],
    value: eFirmware.KLIPPER,
    scope: 'post'
  },
  beginMacro: {
		title: 'Start Macro',
    description: 'Macro to run at the start of the job',
    group: 'job',
    type: 'string',
    default_mm: '',
    default_in: '',
    value: '',
    scope: 'post'
  },
  endMacro: {
		title: 'End Macro',
    description: 'Macro to run at the end of the job',
    group: 'job',
    type: 'string',
    default_mm: '',
    default_in: '',
    value: '',
    scope: 'post'
  },
  initializeOriginAtStart: {
    title: 'Zero Starting Location (G92)',
    description: 'On start set the current location as 0,0,0 (G92)',
    group: 'hardware',
    type: 'boolean',
    default_mm: false,
    default_in: false,
    value: false,
    scope: 'post'
  },
	returnToOriginAtEnd: {
    title: 'At end go to 0,0',
    description: 'Go to X0 Y0 at gcode end, Z remains unchanged',
    group: 'hardware',
    type: 'boolean',
    default_mm: false,
    default_in: false,
    value: false,
    scope: 'post'
  },
  manualSpindlePowerControl: {
    title: 'Manual Spindle On/Off',
    description: 'Enable to manually turn spindle motor on/off',
    group: 'hardware',
    type: 'boolean',
    default_mm: false,
    default_in: false,
    value: false,
    scope: 'post'
  },
  jobCommentLevel: {
    title: 'Comment Level',
    description: 'Controls the comments include',
    group: 'job',
    type: 'integer',
    default_mm: eComment.Info,
    default_in: eComment.Info,
    values: [
      { title: eComment.prop[eComment.Off].name, id: eComment.Off },
      { title: eComment.prop[eComment.Important].name, id: eComment.Important },
      { title: eComment.prop[eComment.Info].name, id: eComment.Info },
      { title: eComment.prop[eComment.Debug].name, id: eComment.Debug }
    ],
    value: eComment.Info,
    scope: 'post'
  },
  useArcs: {
    title: 'Use Arcs',
    description: 'Use G2/G3 g-codes fo circular movements',
    group: 'hardware',
    type: 'boolean',
    default_mm: false,
    default_in: true,
    value: false,
    scope: 'post'
  },
  enableSequenceNumbers: {
    title: 'Enable Line Numbers',
    description: 'Show sequence numbers',
    group: 'jobSequence',
    type: 'boolean',
    default_mm: false,
    default_in: false,
    value: false,
    scope: 'post'
  },
  sequenceNumberStart: {
    title: 'First Line Number',
    description: 'First sequence number',
    group: 'jobSequence',
    type: 'integer',
    default_mm: 10,
    default_in: 10,
    value: 10,
    scope: 'post'
  },
  sequenceNumberIncrement: {
    title: 'Line Number Increment',
    description: 'Sequence number increment',
    group: 'jobSequence',
    type: 'integer',
    default_mm: 1,
    default_in: 1,
    value: 1,
    scope: 'post'
  },
  separateWordsWithSpace: {
    title: 'Include Whitespace',
    description: 'Includes whitespace seperation between text',
    group: 'job',
    type: 'boolean',
    default_mm: true,
    default_in: true,
    value: true,
    scope: 'post'
  },
  frameAtStart: {
    title: 'Move around frame at start',
    description:
      'Perform framing movements at the start of the job. Requires a PAUSE macro',
    group: 'framing',
    type: 'boolean',
    default_mm: false,
    default_in: false,
    value: false,
    scope: 'post'
  },
  frameLoops: {
    title: 'Number of framing loops',
    description: 'Number of times to move around the frame area',
    group: 'framing',
    type: 'integer',
    default_mm: 2,
    default_in: 2,
    value: 2,
    scope: 'post'
  },
  pauseAfterFrame: {
    title: 'Pause after framing',
    description:
      'Call the PAUSE macro after framing is complete before starting the job',
    group: 'framing',
    type: 'boolean',
    default_mm: true,
    default_in: true,
    value: true,
    scope: 'post'
  },
  travelSpeedXY: {
    title: 'Travel speed X/Y',
    description: 'High speed for Rapid movements X & Y (mm/min; in/min)',
    group: 'speeds',
    type: 'spatial',
    default_mm: 2400,
    default_in: 100,
    value: 2400,
    scope: 'post'
  },
  travelSpeedZ: {
    title: 'Travel Speed Z',
    description: 'High speed for Rapid movements z (mm/min; in/min)',
    group: 'speeds',
    type: 'spatial',
    default_mm: 500,
    default_in: 12,
    value: 500,
    scope: 'post'
  },
  enforceFeedrate: {
    title: 'Enforce Feedrate',
    description: 'Add feedrate to each movement g-code',
    group: 'speeds',
    type: 'boolean',
    default_mm: true,
    default_in: true,
    value: true,
    scope: 'post'
  },
  scaleFeedrate: {
    title: 'Scale Feedrate',
    description: 'Scale feedrate based on X, Y, Z axis maximums',
    group: 'speeds',
    type: 'boolean',
    default_mm: false,
    default_in: false,
    value: false,
    scope: 'post'
  },
  maxCutSpeedXY: {
    title: 'Max XY Cut Speed',
    description: 'Maximum X or Y axis cut speed (mm/min; in/min)',
    group: 'speeds',
    type: 'spatial',
    default_mm: 600,
    default_in: 35.43,
    value: 600,
    scope: 'post'
  },
  maxCutSpeedZ: {
    title: 'Max Z Cut Speed',
    description: 'Maximum Z axis cut speed (mm/min; in/min)',
    group: 'speeds',
    type: 'spatial',
    default_mm: 180,
    default_in: 7.08,
    value: 180,
    scope: 'post'
  },
  maxCutSpeedXYZ: {
    title: 'Max Toolpath Speed',
    description: 'Maximum scaled feedrate for toolpath (mm/min; in/min)',
    group: 'speeds',
    type: 'spatial',
    default_mm: 1000,
    default_in: 39.37,
    value: 1000,
    scope: 'post'
  },
  restoreFirstRapids: {
    title: 'First G1 -> G0 Rapid',
    description: 'Ensure move to start of a cut is with a G0 Rapid',
    group: 'rapidMoves',
    type: 'boolean',
    default_mm: true,
    default_in: true,
    value: true,
    scope: 'post'
  },
  restoreRapids: {
    title: 'G1s -> G0 Rapids',
    description: 'Enable to convert G1s to G0 Rapids when safe',
    group: 'rapidMoves',
    type: 'boolean',
    default_mm: true,
    default_in: true,
    value: true,
    scope: 'post'
  },
  safeZ: {
    title: 'Safe Z to Rapid',
    description:
      'Must be above or equal to this value to map G1s --> G0s; constant or keyword (see docs)',
    group: 'rapidMoves',
    type: 'string',
    default_mm: 'Retract:5',
    default_in: 'Retract:5',
    value: 'Retract:5',
    scope: 'post'
  },
  allowRapidZ: {
    title: 'Allow Rapid Z',
    description: 'Enable to include vertical retracts and safe descents',
    group: 'rapidMoves',
    type: 'boolean',
    default_mm: false,
    default_in: false,
    value: false,
    scope: 'post'
  },
  toolChangeEnabled: {
    title: 'Enable Tool Changes',
    description:
      'Include tool change code when tool changes (bultin tool change requires LCD display)',
    group: 'toolChanger',
    type: 'boolean',
    default_mm: false,
    default_in: false,
    value: false,
    scope: 'post'
  },
  toolChangeX: {
    title: 'Toolchanger X Position',
    description: 'X location for tool change',
    group: 'toolChanger',
    type: 'spatial',
    default_mm: 0,
    default_in: 0,
    value: 0,
    scope: 'post'
  },
  toolChangeY: {
    title: 'Toolchanger Y Position',
    description: 'Y location for tool change',
    group: 'toolChanger',
    type: 'spatial',
    default_mm: 0,
    default_in: 0,
    value: 0,
    scope: 'post'
  },
  toolChangeZ: {
    title: 'Toolchanger Z Position',
    description: 'Z location for tool change',
    group: 'toolChanger',
    type: 'spatial',
    default_mm: 40,
    default_in: 1.6,
    value: 40,
    scope: 'post'
  },
  toolChangeDisableZStepper: {
    title: 'Disable Z stepper after moving',
    description: 'Disable Z stepper after reaching tool change location',
    group: 'toolChanger',
    type: 'boolean',
    default_mm: false,
    default_in: false,
    value: false,
    scope: 'post'
  },
  probeAtStart: {
    title: 'Probe On job start',
    description: 'Execute probe gcode on job start',
    group: 'probing',
    type: 'boolean',
    default_mm: false,
    default_in: false,
    value: false,
    scope: 'post'
  },
  probeAfterToolChange: {
    title: 'Probe After Tool Change',
    description: 'After tool change, probe Z at the current location',
    group: 'probing',
    type: 'boolean',
    default_mm: false,
    default_in: false,
    value: false,
    scope: 'post'
  },
  probeThickness: {
    title: 'Plate thickness',
    description: 'Plate thickness',
    group: 'probing',
    type: 'spatial',
    default_mm: 0.8,
    default_in: 0.032,
    value: 0.8,
    scope: 'post'
  },
  probeHomeZ: {
    title: 'Use Home Z (G28)',
    description: 'Probe with G28 (Yes) or G38 (No)',
    group: 'probing',
    type: 'boolean',
    default_mm: true,
    default_in: true,
    value: true,
    scope: 'post'
  },
  probeG38Target: {
    title: 'G38 target',
    description: "G38 Probing's furthest Z position",
    group: 'probing',
    type: 'spatial',
    default_mm: -10,
    default_in: -0.5,
    value: -10,
    scope: 'post'
  },
  probeG38Speed: {
    title: 'G38 speed',
    description: "G38 Probing's speed (mm/min; in/min)",
    group: 'probing',
    type: 'spatial',
    default_mm: 30,
    default_in: 1.2,
    value: 30,
    scope: 'post'
  },
  cutterOnVaporize: {
    title: 'On - Vaporize',
    description:
      'Persent of power to turn on the laser/plasma cutter in vaporize mode',
    group: 'laser',
    type: 'number',
    default_mm: 100,
    default_in: 100,
    value: 100,
    scope: 'post'
  },
  cutterOnThrough: {
    title: 'On - Through',
    description:
      'Persent of power to turn on the laser/plasma cutter in through mode',
    group: 'laser',
    type: 'number',
    default_mm: 80,
    default_in: 80,
    value: 80,
    scope: 'post'
  },
  cutterOnEtch: {
    title: 'On - Etch',
    description: 'Persent of power to on the laser/plasma cutter in etch mode',
    group: 'laser',
    type: 'number',
    default_mm: 40,
    default_in: 40,
    value: 40,
    scope: 'post'
  },
  cutterMode: {
    title: 'Mode',
    description: 'Mode of the laser/plasma cutter',
    group: 'laser',
    type: 'integer',
    default_mm: 106,
    default_in: 106,
    values: [
      { title: 'Fan - M106 S{PWM}/M107', id: 106 },
      { title: 'Spindle - M3 O{PWM}/M5', id: 3 },
      { title: 'Pin - M42 P{pin} S{PWM}', id: 42 }
    ],
    value: 106,
    scope: 'post'
  },
  cutterPin: {
    title: 'M42 Pin',
    description: 'Custom pin number for the laser/plasma cutter',
    group: 'laser',
    type: 'integer',
    default_mm: 4,
    default_in: 4,
    value: 4,
    scope: 'post'
  },
  cutterCoolant: {
    title: 'Coolant',
    description: 'Force a coolant to be used',
    group: 'laser',
    type: 'integer',
    default_mm: eCoolant.Off,
    default_in: eCoolant.Off,
    values: [
      { title: eCoolant.prop[eCoolant.Off].name, id: eCoolant.Off },
      { title: eCoolant.prop[eCoolant.Flood].name, id: eCoolant.Flood },
      { title: eCoolant.prop[eCoolant.Mist].name, id: eCoolant.Mist },
      {
        title: eCoolant.prop[eCoolant.ThroughTool].name,
        id: eCoolant.ThroughTool
      },
      { title: eCoolant.prop[eCoolant.Air].name, id: eCoolant.Air },
      {
        title: eCoolant.prop[eCoolant.AirThroughTool].name,
        id: eCoolant.AirThroughTool
      },
      { title: eCoolant.prop[eCoolant.Suction].name, id: eCoolant.Suction },
      { title: eCoolant.prop[eCoolant.FloodMist].name, id: eCoolant.FloodMist },
      {
        title: eCoolant.prop[eCoolant.FloodThroughTool].name,
        id: eCoolant.FloodThroughTool
      }
    ],
    value: eCoolant.Off,
    scope: 'post'
  },

  gcodeStartFile: {
    title: 'Start File',
    description: 'File with custom Gcode for header/start (in nc folder)',
    group: 'externalFiles',
    type: 'file',
    default_mm: '',
    default_in: '',
    value: '',
    scope: 'post'
  },
  gcodeStopFile: {
    title: 'Stop File',
    description: 'File with custom Gcode for footer/end (in nc folder)',
    group: 'externalFiles',
    type: 'file',
    default_mm: '',
    default_in: '',
    value: '',
    scope: 'post'
  },
  gcodeToolFile: {
    title: 'Tool File',
    description: 'File with custom Gcode for tool change (in nc folder)',
    group: 'externalFiles',
    type: 'file',
    default_mm: '',
    default_in: '',
    value: '',
    scope: 'post'
  },
  gcodeProbeFile: {
    title: 'Probe File',
    description: 'File with custom Gcode for tool probe (in nc folder)',
    group: 'externalFiles',
    type: 'file',
    default_mm: '',
    default_in: '',
    value: '',
    scope: 'post'
  },

  // Coolant
  coolantAMode: {
    title: 'Coolant A Mode',
    description: 'Enable channel A when tool is set this coolant',
    group: 'coolant',
    type: 'integer',
    default_mm: 0,
    default_in: 0,
    values: [
      { title: eCoolant.prop[eCoolant.Off].name, id: eCoolant.Off },
      { title: eCoolant.prop[eCoolant.Flood].name, id: eCoolant.Flood },
      { title: eCoolant.prop[eCoolant.Mist].name, id: eCoolant.Mist },
      {
        title: eCoolant.prop[eCoolant.ThroughTool].name,
        id: eCoolant.ThroughTool
      },
      { title: eCoolant.prop[eCoolant.Air].name, id: eCoolant.Air },
      {
        title: eCoolant.prop[eCoolant.AirThroughTool].name,
        id: eCoolant.AirThroughTool
      },
      { title: eCoolant.prop[eCoolant.Suction].name, id: eCoolant.Suction },
      { title: eCoolant.prop[eCoolant.FloodMist].name, id: eCoolant.FloodMist },
      {
        title: eCoolant.prop[eCoolant.FloodThroughTool].name,
        id: eCoolant.FloodThroughTool
      }
    ],
    value: 0,
    scope: 'post'
  },
  coolantBMode: {
    title: 'Coolant B Mode',
    description: 'Enable channel B when tool is set this coolant',
    group: 'coolant',
    type: 'integer',
    default_mm: 0,
    default_in: 0,
    values: [
      { title: eCoolant.prop[eCoolant.Off].name, id: eCoolant.Off },
      { title: eCoolant.prop[eCoolant.Flood].name, id: eCoolant.Flood },
      { title: eCoolant.prop[eCoolant.Mist].name, id: eCoolant.Mist },
      {
        title: eCoolant.prop[eCoolant.ThroughTool].name,
        id: eCoolant.ThroughTool
      },
      { title: eCoolant.prop[eCoolant.Air].name, id: eCoolant.Air },
      {
        title: eCoolant.prop[eCoolant.AirThroughTool].name,
        id: eCoolant.AirThroughTool
      },
      { title: eCoolant.prop[eCoolant.Suction].name, id: eCoolant.Suction },
      { title: eCoolant.prop[eCoolant.FloodMist].name, id: eCoolant.FloodMist },
      {
        title: eCoolant.prop[eCoolant.FloodThroughTool].name,
        id: eCoolant.FloodThroughTool
      }
    ],
    value: 0,
    scope: 'post'
  },
  coolantAOn: {
    title: 'Coolant A Enable',
    description: 'GCode to turn On coolant channel A',
    group: 'coolant',
    type: 'enum',
    default_mm: 'M42 P6 S255',
    default_in: 'M42 P6 S255',
    values: [
      { title: 'Mrln: M42 P6 S255', id: 'M42 P6 S255' },
      { title: 'Mrln: M42 P11 S255', id: 'M42 P11 S255' },
      { title: 'Grbl: M7 (mist)', id: 'M7' },
      { title: 'Grbl: M8 (flood)', id: 'M8' },
      { title: 'Use custom', id: 'Use custom' }
    ],
    value: 'M42 P6 S255',
    scope: 'post'
  },
  coolantAOff: {
    title: 'Coolant A Disable',
    description: 'Gcode to turn Off coolant A',
    group: 'coolant',
    type: 'enum',
    default_mm: 'M42 P6 S0',
    default_in: 'M42 P6 S0',
    values: [
      { title: 'Mrln: M42 P6 S0', id: 'M42 P6 S0' },
      { title: 'Mrln: M42 P11 S0', id: 'M42 P11 S0' },
      { title: 'Grbl: M9 (off)', id: 'M9' },
      { title: 'Use custom', id: 'Use custom' }
    ],
    value: 'M42 P6 S0',
    scope: 'post'
  },
  coolantBOn: {
    title: 'Coolant B Enable',
    description: 'GCode to turn On coolant channel B',
    group: 'coolant',
    type: 'enum',
    default_mm: 'M42 P11 S255',
    default_in: 'M42 P11 S255',
    values: [
      { title: 'Mrln: M42 P11 S255', id: 'M42 P11 S255' },
      { title: 'Mrln: M42 P6 S255', id: 'M42 P6 S255' },
      { title: 'Grbl: M7 (mist)', id: 'M7' },
      { title: 'Grbl: M8 (flood)', id: 'M8' },
      { title: 'Use custom', id: 'Use custom' }
    ],
    value: 'M42 P11 S255',
    scope: 'post'
  },
  coolantBOff: {
    title: 'Coolant B Disable',
    description: 'Gcode to turn Off coolant B',
    group: 'coolant',
    type: 'enum',
    default_mm: 'M42 P11 S0',
    default_in: 'M42 P11 S0',
    values: [
      { title: 'Mrln: M42 P11 S0', id: 'M42 P11 S0' },
      { title: 'Mrln: M42 P6 S0', id: 'M42 P6 S0' },
      { title: 'Grbl: M9 (off)', id: 'M9' },
      { title: 'Use custom', id: 'Use custom' }
    ],
    value: 'M42 P11 S0',
    scope: 'post'
  },
  customCoolantAOn: {
    title: 'Custom A Enable',
    description: 'Custom GCode to turn On coolant channel A',
    group: 'coolant',
    type: 'string',
    default_mm: '',
    default_in: '',
    value: '',
    scope: 'post'
  },
  customCoolantAOff: {
    title: 'Custom A Disable',
    description: 'Custom Gcode to turn Off coolant A',
    group: 'coolant',
    type: 'string',
    default_mm: '',
    default_in: '',
    value: '',
    scope: 'post'
  },
  customCoolantBOn: {
    title: 'Custom B Enable',
    description: 'Custom GCode to turn On coolant channel B',
    group: 'coolant',
    type: 'string',
    default_mm: '',
    default_in: '',
    value: '',
    scope: 'post'
  },
  customCoolantBOff: {
    title: 'Custom B Disable',
    description: 'Custom Gcode to turn Off coolant B',
    group: 'coolant',
    type: 'string',
    default_mm: '',
    default_in: '',
    value: '',
    scope: 'post'
  }
};

var sequenceNumber;

// Formats
var gFormat = createFormat({ prefix: 'G', decimals: 1 });
var mFormat = createFormat({ prefix: 'M', decimals: 0 });

var xyzFormat = createFormat({ decimals: unit == MM ? 3 : 4 });
var xFormat = createFormat({ prefix: 'X', decimals: unit == MM ? 3 : 4 });
var yFormat = createFormat({ prefix: 'Y', decimals: unit == MM ? 3 : 4 });
var zFormat = createFormat({ prefix: 'Z', decimals: unit == MM ? 3 : 4 });
var iFormat = createFormat({ prefix: 'I', decimals: unit == MM ? 3 : 4 });
var jFormat = createFormat({ prefix: 'J', decimals: unit == MM ? 3 : 4 });
var kFormat = createFormat({ prefix: 'K', decimals: unit == MM ? 3 : 4 });

var speedFormat = createFormat({ decimals: 0 });
var sFormat = createFormat({ prefix: 'S', decimals: 0 });

var pFormat = createFormat({ prefix: 'P', decimals: 0 });
var oFormat = createFormat({ prefix: 'O', decimals: 0 });

var feedFormat = createFormat({ decimals: unit == MM ? 0 : 2 });
var fFormat = createFormat({ prefix: 'F', decimals: unit == MM ? 0 : 2 });

var toolFormat = createFormat({ decimals: 0 });
var tFormat = createFormat({ prefix: 'T', decimals: 0 });

var taperFormat = createFormat({ decimals: 1, scale: DEG });
var secFormat = createFormat({ decimals: 3, forceDecimal: true }); // seconds - range 0.001-1000

// Linear outputs
var xOutput = createVariable({}, xFormat);
var yOutput = createVariable({}, yFormat);
var zOutput = createVariable({}, zFormat);
var fOutput = createVariable({ force: false }, fFormat);
var sOutput = createVariable({ force: true }, sFormat);

// Circular outputs
var iOutput = createReferenceVariable({}, iFormat);
var jOutput = createReferenceVariable({}, jFormat);
var kOutput = createReferenceVariable({}, kFormat);

// Modals
var gMotionModal = createModal({}, gFormat); // modal group 1 // G0-G3, ...
var gPlaneModal = createModal(
  {
    onchange: function () {
      gMotionModal.reset();
    }
  },
  gFormat
); // modal group 2 // G17-19
var gAbsIncModal = createModal({}, gFormat); // modal group 3 // G90-91
var gFeedModeModal = createModal({}, gFormat); // modal group 5 // G93-94
var gUnitModal = createModal({}, gFormat); // modal group 6 // G20-21

// Arc support variables
minimumChordLength = spatial(0.01, MM);
minimumCircularRadius = spatial(0.01, MM);
maximumCircularRadius = spatial(1000, MM);
minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(180);
allowHelicalMoves = false;
allowedCircularPlanes = undefined;

// Writes the specified block.
function writeBlock() {
  if (properties.enableSequenceNumbers) {
    writeWords2('N' + sequenceNumber, arguments);
    sequenceNumber += properties.sequenceNumberIncrement;
  } else {
    writeWords(arguments);
  }
}

function flushMotions() {
  // Default
  writeBlock(mFormat.format(400));
}

//---------------- Safe Rapids ----------------

var eSafeZ = {
  CONST: 0,
  FEED: 1,
  RETRACT: 2,
  CLEARANCE: 3,
  ERROR: 4,
  prop: {
    0: {
      name: 'Const',
      regex: /^\d+\.?\d*$/,
      numRegEx: /^(\d+\.?\d*)$/,
      value: 0
    },
    1: { name: 'Feed', regex: /^Feed:/i, numRegEx: /:(\d+\.?\d*)$/, value: 1 },
    2: {
      name: 'Retract',
      regex: /^Retract:/i,
      numRegEx: /:(\d+\.?\d*)$/,
      alue: 2
    },
    3: {
      name: 'Clearance',
      regex: /^Clearance:/i,
      numRegEx: /:(\d+\.?\d*)$/,
      value: 3
    },
    4: { name: 'Error', regex: /^$/, numRegEx: /^$/, value: 4 }
  }
};

var safeZMode = eSafeZ.CONST;
var safeZHeightDefault = 15;
var safeZHeight;

function parseSafeZProperty() {
  var str = properties.safeZ;

  // Look for either a number by itself or 'Feed:', 'Retract:' or 'Clearance:'
  for (safeZMode = eSafeZ.CONST; safeZMode < eSafeZ.ERROR; safeZMode++) {
    if (str.search(eSafeZ.prop[safeZMode].regex) == 0) {
      break;
    }
  }

  // If it was not an error then get the number
  if (safeZMode != eSafeZ.ERROR) {
    safeZHeightDefault = str.match(eSafeZ.prop[safeZMode].numRegEx);

    if (safeZHeightDefault == null || safeZHeightDefault.length != 2) {
      writeComment(
        eComment.Debug,
        ' parseSafeZProperty: ' + safeZHeightDefault
      );
      writeComment(
        eComment.Debug,
        ' parseSafeZProperty.length: ' +
          (safeZHeightDefault != null ? safeZHeightDefault.length : 'na')
      );
      writeComment(eComment.Debug, " parseSafeZProperty: Couldn't find number");
      safeZMode = eSafeZ.ERROR;
      safeZHeightDefault = 15;
    } else {
      safeZHeightDefault = safeZHeightDefault[1];
    }
  }

  writeComment(
    eComment.Debug,
    " parseSafeZProperty: safeZMode = '" + eSafeZ.prop[safeZMode].name + "'"
  );
  writeComment(
    eComment.Debug,
    ' parseSafeZProperty: safeZHeightDefault = ' + safeZHeightDefault
  );
}

function safeZforSection(_section) {
  if (properties.restoreRapids) {
    switch (safeZMode) {
      case eSafeZ.CONST:
        safeZHeight = safeZHeightDefault;
        writeComment(eComment.Important, ' SafeZ using const: ' + safeZHeight);
        break;

      case eSafeZ.FEED:
        if (
          hasParameter('operation:feedHeight_value') &&
          hasParameter('operation:feedHeight_absolute')
        ) {
          let feed = _section.getParameter('operation:feedHeight_value');
          let abs = _section.getParameter('operation:feedHeight_absolute');

          if (abs == 1) {
            safeZHeight = feed;
            writeComment(eComment.Info, ' SafeZ feed level: ' + safeZHeight);
          } else {
            safeZHeight = safeZHeightDefault;
            writeComment(
              eComment.Important,
              ' SafeZ feed level not abs: ' + safeZHeight
            );
          }
        } else {
          safeZHeight = safeZHeightDefault;
          writeComment(
            eComment.Important,
            ' SafeZ feed level not defined: ' + safeZHeight
          );
        }
        break;

      case eSafeZ.RETRACT:
        if (
          hasParameter('operation:retractHeight_value') &&
          hasParameter('operation:retractHeight_absolute')
        ) {
          let retract = _section.getParameter('operation:retractHeight_value');
          let abs = _section.getParameter('operation:retractHeight_absolute');

          if (abs == 1) {
            safeZHeight = retract;
            writeComment(eComment.Info, ' SafeZ retract level: ' + safeZHeight);
          } else {
            safeZHeight = safeZHeightDefault;
            writeComment(
              eComment.Important,
              ' SafeZ retract level not abs: ' + safeZHeight
            );
          }
        } else {
          safeZHeight = safeZHeightDefault;
          writeComment(
            eComment.Important,
            ' SafeZ: retract level not defined: ' + safeZHeight
          );
        }
        break;

      case eSafeZ.CLEARANCE:
        if (
          hasParameter('operation:clearanceHeight_value') &&
          hasParameter('operation:clearanceHeight_absolute')
        ) {
          var clearance = _section.getParameter(
            'operation:clearanceHeight_value'
          );
          let abs = _section.getParameter('operation:clearanceHeight_absolute');

          if (abs == 1) {
            safeZHeight = clearance;
            writeComment(
              eComment.Info,
              ' SafeZ clearance level: ' + safeZHeight
            );
          } else {
            safeZHeight = safeZHeightDefault;
            writeComment(
              eComment.Important,
              ' SafeZ clearance level not abs: ' + safeZHeight
            );
          }
        } else {
          safeZHeight = safeZHeightDefault;
          writeComment(
            eComment.Important,
            ' SafeZ clearance level not defined: ' + safeZHeight
          );
        }
        break;

      case eSafeZ.ERROR:
        safeZHeight = safeZHeightDefault;
        writeComment(
          eComment.Important,
          ' >>> WARNING: ' +
            propertyDefinitions.mapF_SafeZ.title +
            'format error: ' +
            safeZHeight
        );
        break;
    }
  }
}

Number.prototype.round = function (places) {
  return +(Math.round(this + 'e+' + places) + 'e-' + places);
};

// Returns true if the rules to convert G1s to G0s are satisfied
function isSafeToRapid(x, y, z) {
  if (properties.restoreRapids) {
    // Calculat a z to 3 decimal places for zSafe comparison, every where else use z to avoid mixing rounded with unrounded
    var z_round = z.round(3);
    writeComment(
      eComment.Debug,
      'isSafeToRapid z: ' + z + ' z_round: ' + z_round
    );

    let zSafe = z_round >= safeZHeight;

    writeComment(
      eComment.Debug,
      'isSafeToRapid zSafe: ' +
        zSafe +
        ' z_round: ' +
        z_round +
        ' safeZHeight: ' +
        safeZHeight
    );

    // Destination z must be in safe zone.
    if (zSafe) {
      let cur = getCurrentPosition();
      let zConstant = z == cur.z;
      let zUp = z > cur.z;
      let xyConstant = x == cur.x && y == cur.y;
      let curZSafe = cur.z >= safeZHeight;
      writeComment(
        eComment.Debug,
        'isSafeToRapid curZSafe: ' + curZSafe + ' cur.z: ' + cur.z
      );

      // Restore Rapids only when the target Z is safe and
      //   Case 1: Z is not changing, but XY are
      //   Case 2: Z is increasing, but XY constant

      // Z is not changing and we know we are in the safe zone
      if (zConstant) {
        return true;
      }

      // We include moves of Z up as long as xy are constant
      else if (properties.allowRapidZ && zUp && xyConstant) {
        return true;
      }

      // We include moves of Z down as long as xy are constant and z always remains safe
      else if (properties.allowRapidZ && !zUp && xyConstant && curZSafe) {
        return true;
      }
    }
  }

  return false;
}

//---------------- Coolant ----------------

function CoolantA(on) {
  var coolantText = on ? properties.coolantAOn : properties.coolantAOff;

  if (coolantText == 'Use custom') {
    coolantText = on
      ? properties.customCoolantAOn
      : properties.customCoolantAOff;
  }

  writeBlock(coolantText);
}

function CoolantB(on) {
  var coolantText = on ? properties.coolantBOn : properties.coolantBOff;

  if (coolantText == 'Use custom') {
    coolantText = on
      ? properties.customCoolantBOn
      : properties.customCoolantBOff;
  }

  writeBlock(coolantText);
}

// Manage two channels of coolant by tracking which coolant is being using for
// a channel (0 = disabled). SetCoolant called with desired coolant to use or 0 to disable

var curCoolant = eCoolant.Off; // The coolant requested by the tool
var coolantChannelA = eCoolant.Off; // The coolant running in ChannelA
var coolantChannelB = eCoolant.Off; // The coolant running in ChannelB

function setCoolant(coolant) {
  writeComment(
    eComment.Debug,
    ' ---- Coolant: ' +
      coolant +
      ' cur: ' +
      curCoolant +
      ' A: ' +
      coolantChannelA +
      ' B: ' +
      coolantChannelB
  );

  // If the coolant for this tool is the same as the current coolant then there is nothing to do
  if (curCoolant == coolant) {
    return;
  }

  // We are changing coolant, so disable any active coolant channels
  // before we switch to the other coolant
  if (coolantChannelA != eCoolant.Off) {
    writeComment(
      coolant == eCoolant.Off ? eComment.Important : eComment.Info,
      ' >>> Coolant Channel A: ' + eCoolant.prop[eCoolant.Off].name
    );
    coolantChannelA = eCoolant.Off;
    CoolantA(false);
  }

  if (coolantChannelB != eCoolant.Off) {
    writeComment(
      coolant == eCoolant.Off ? eComment.Important : eComment.Info,
      ' >>> Coolant Channel B: ' + eCoolant.prop[eCoolant.Off].name
    );
    coolantChannelB = eCoolant.Off;
    CoolantB(false);
  }

  // At this point we know that all coolant is off so make that the current coolant
  curCoolant = eCoolant.Off;

  // As long as we are not disabling coolant (coolant = 0), then check if either coolant channel
  // matches the coolant requested. If neither do then issue an warning

  var warn = true;

  if (coolant != eCoolant.Off) {
    if (properties.coolantAMode == coolant) {
      writeComment(
        eComment.Important,
        ' >>> Coolant Channel A: ' + eCoolant.prop[coolant].name
      );
      coolantChannelA = coolant;
      curCoolant = coolant;
      warn = false;
      CoolantA(true);
    }

    if (properties.coolantBMode == coolant) {
      writeComment(
        eComment.Important,
        ' >>> Coolant Channel B: ' + eCoolant.prop[coolant].name
      );
      coolantChannelB = coolant;
      curCoolant = coolant;
      warn = false;
      CoolantB(true);
    }

    if (warn) {
      writeComment(
        eComment.Important,
        ' >>> WARNING: No matching Coolant channel : ' +
          (coolant <= eCoolant.FloodThroughTool
            ? eCoolant.prop[coolant].name
            : 'unknown') +
          ' requested'
      );
    }
  }
}

//---------------- Cutters - Waterjet/Laser/Plasma ----------------

var cutterOnCurrentPower;

function laserOn(power) {
  // Default firmware

  var laser_pwm = (power / 100) * 255;

  switch (properties.cutterMode) {
    case 106:
      writeBlock(mFormat.format(106), sFormat.format(laser_pwm));
      break;
    case 3:
      if (fw == eFirmware.KLIPPER) {
        writeBlock(mFormat.format(3), sFormat.format(laser_pwm));
      } else {
        writeBlock(mFormat.format(3), oFormat.format(laser_pwm));
      }
      break;
    case 42:
      writeBlock(
        mFormat.format(42),
        pFormat.format(properties.cutterPin),
        sFormat.format(laser_pwm)
      );
      break;
  }
}

function laserOff() {
  // Default
  switch (properties.cutterMode) {
    case 106:
      writeBlock(mFormat.format(107));
      break;
    case 3:
      writeBlock(mFormat.format(5));
      break;
    case 42:
      writeBlock(
        mFormat.format(42),
        pFormat.format(properties.cutterPin),
        sFormat.format(0)
      );
      break;
  }
}

//---------------- on Entry Points ----------------

// Called in every new gcode file
function onOpen() {
  fw = properties.controllerFirmware;

  gMotionModal = createModal({ force: true }, gFormat); // modal group 1 // G0-G3, ...

  // Configure how the feedrate is formatted
  if (properties.enforceFeedrate) {
    fOutput = createVariable({ force: true }, fFormat);
  }

  // Set the starting sequence number for line numbering
  sequenceNumber = properties.sequenceNumberStart;

  // Set the seperator used between text
  if (!properties.separateWordsWithSpace) {
    setWordSeparator('');
  }

  // Determine the safeZHeight to do rapids
  parseSafeZProperty();
}

// Called at end of gcode file
function onClose() {
  writeComment(eComment.Important, ' *** STOP begin ***');

  flushMotions();

  if (properties.gcodeStopFile == '') {
    onCommand(COMMAND_COOLANT_OFF);
    if (properties.returnToOriginAtEnd) {
      rapidMovementsXY(0, 0);
    }
    onCommand(COMMAND_STOP_SPINDLE);

    end(true);

    writeComment(eComment.Important, ' *** STOP end ***');
  } else {
    loadFile(properties.gcodeStopFile);
  }
}

var forceSectionToStartWithRapid = false;

function onSection() {
  // Every section needs to start with a Rapid to get to the initial location.
  // In the hobby version Rapids have been elliminated and the first command is
  // a onLinear not a onRapid command. This results in not current position being
  // that same as the cut to position which means wecan't determine the direction
  // of the move. Without a direction vector we can't scale the feedrate or convert
  // onLinear moves back into onRapids. By ensuring the first onLinear is treated as
  // a onRapid we have a currentPosition that is correct.

  forceSectionToStartWithRapid = true;

  // Write Start gcode of the documment (after the "onParameters" with the global info)
  if (isFirstSection()) {
    writeFirstSection();
  }

  writeComment(eComment.Important, ' *** SECTION begin ***');

  // Print min/max boundaries for each section
  vectorX = new Vector(1, 0, 0);
  vectorY = new Vector(0, 1, 0);
  writeComment(
    eComment.Info,
    '   X Min: ' +
      xyzFormat.format(currentSection.getGlobalRange(vectorX).getMinimum()) +
      ' - X Max: ' +
      xyzFormat.format(currentSection.getGlobalRange(vectorX).getMaximum())
  );
  writeComment(
    eComment.Info,
    '   Y Min: ' +
      xyzFormat.format(currentSection.getGlobalRange(vectorY).getMinimum()) +
      ' - Y Max: ' +
      xyzFormat.format(currentSection.getGlobalRange(vectorY).getMaximum())
  );
  writeComment(
    eComment.Info,
    '   Z Min: ' +
      xyzFormat.format(currentSection.getGlobalZRange().getMinimum()) +
      ' - Z Max: ' +
      xyzFormat.format(currentSection.getGlobalZRange().getMaximum())
  );

  // Determine the Safe Z Height to map G1s to G0s
  safeZforSection(currentSection);

  // Do a tool change if tool changes are enabled and its not the first section and this section uses
  // a different tool then the previous section
  if (
    properties.toolChangeEnabled &&
    !isFirstSection() &&
    tool.number != getPreviousSection().getTool().number
  ) {
    if (properties.gcodeToolFile == '') {
      // Post Processor does the tool change

      writeComment(eComment.Important, ' --- Tool Change Start');
      toolChange();
      writeComment(eComment.Important, ' --- Tool Change End');
    } else {
      // Users custom tool change gcode is used
      loadFile(properties.gcodeToolFile);
    }
  }

  // Machining type
  if (currentSection.type == TYPE_MILLING) {
    // Specific milling code
    writeComment(
      eComment.Info,
      ' ' +
        sectionComment +
        ' - Milling - Tool: ' +
        tool.number +
        ' - ' +
        tool.comment +
        ' ' +
        getToolTypeName(tool.type)
    );
  } else if (currentSection.type == TYPE_JET) {
    var jetModeStr;
    var warn = false;

    // Cutter mode used for different cutting power in PWM laser
    switch (currentSection.jetMode) {
      case JET_MODE_THROUGH:
        cutterOnCurrentPower = properties.cutterOnThrough;
        jetModeStr = 'Through';
        break;
      case JET_MODE_ETCHING:
        cutterOnCurrentPower = properties.cutterOnEtch;
        jetModeStr = 'Etching';
        break;
      case JET_MODE_VAPORIZE:
        jetModeStr = 'Vaporize';
        cutterOnCurrentPower = properties.cutterOnVaporize;
        break;
      default:
        jetModeStr = '*** Unknown ***';
        warn = true;
    }

    if (warn) {
      writeComment(
        eComment.Info,
        ' ' +
          sectionComment +
          ', Laser/Plasma Cutting mode: ' +
          getParameter('operation:cuttingMode') +
          ', jetMode: ' +
          jetModeStr
      );
      writeComment(
        eComment.Important,
        'Selected cutting mode ' +
          currentSection.jetMode +
          ' not mapped to power level'
      );
    } else {
      writeComment(
        eComment.Info,
        ' ' +
          sectionComment +
          ', Laser/Plasma Cutting mode: ' +
          getParameter('operation:cuttingMode') +
          ', jetMode: ' +
          jetModeStr +
          ', power: ' +
          cutterOnCurrentPower
      );
    }
  }

  machineMode = currentSection.type;

  onCommand(COMMAND_START_SPINDLE);
  onCommand(COMMAND_COOLANT_ON);

  // Display section name in LCD
  display_text(' ' + sectionComment);
}

// Called in every section end
function onSectionEnd() {
  resetAll();
  writeComment(eComment.Important, ' *** SECTION end ***');
  writeComment(eComment.Important, '');
}

function onComment(message) {
  writeComment(eComment.Important, message);
}

var pendingRadiusCompensation = RADIUS_COMPENSATION_OFF;

function onRadiusCompensation() {
  pendingRadiusCompensation = radiusCompensation;
}

// Rapid movements
function onRapid(x, y, z) {
  forceSectionToStartWithRapid = false;

  rapidMovements(x, y, z);
}

// Feed movements
function onLinear(x, y, z, feed) {
  // If we are allowing Rapids to be recovered from Linear (cut) moves, which is
  // only required when F360 Personal edition is used, then if this Linear (cut)
  // move is the first operationin a Section (milling operation) then convert it
  // to a Rapid. This is OK because Sections normally begin with a Rapid to move
  // to the first cutting location but these Rapids were changed to Linears by
  // the personal edition. If this Rapid is not recovered and feedrate scaling
  // is enabled then the first move to the start of a section will be at the
  // slowest cutting feedrate, generally Z's feedrate.

  if (
    properties.restoreFirstRapids &&
    forceSectionToStartWithRapid == true
  ) {
    writeComment(eComment.Important, ' First G1 --> G0');

    forceSectionToStartWithRapid = false;
    onRapid(x, y, z);
  } else if (isSafeToRapid(x, y, z)) {
    writeComment(eComment.Important, ' Safe G1 --> G0');

    onRapid(x, y, z);
  } else {
    linearMovements(x, y, z, feed, true);
  }
}

function onRapid5D(_x, _y, _z, _a, _b, _c) {
  forceSectionToStartWithRapid = false;

  error(localize('Multi-axis motion is not supported.'));
}

function onLinear5D(_x, _y, _z, _a, _b, _c, feed) {
  forceSectionToStartWithRapid = false;

  error(localize('Multi-axis motion is not supported.'));
}

function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
  forceSectionToStartWithRapid = false;

  if (pendingRadiusCompensation != RADIUS_COMPENSATION_OFF) {
    error(
      localize(
        'Radius compensation cannot be activated/deactivated for a circular move.'
      )
    );
    return;
  }
  circular(clockwise, cx, cy, cz, x, y, z, feed);
}

// Called on waterjet/plasma/laser cuts
var powerState = false;

function onPower(power) {
  if (power != powerState) {
    if (power) {
      writeComment(eComment.Important, ' >>> LASER Power ON');

      laserOn(cutterOnCurrentPower);
    } else {
      writeComment(eComment.Important, ' >>> LASER Power OFF');

      laserOff();
    }
    powerState = power;
  }
}

// Called on Dwell Manual NC invocation
function onDwell(seconds) {
  writeComment(eComment.Important, ' >>> Dwell');
  if (seconds > 99999.999) {
    warning(localize('Dwelling time is out of range.'));
  }

  milliseconds = clamp(0.001, seconds, 99999.999);
  // Updated for Klipper which accepts milliseconds
  writeBlock(gFormat.format(4), 'P' + secFormat.format(seconds * 1000));
}

// Called with every parameter in the documment/section
function onParameter(name, value) {
  // Write gcode initial info
  // Product version
  if (name == 'generated-by') {
    writeComment(eComment.Important, value);
    writeComment(
      eComment.Important,
      ' Posts processor: ' + FileSystem.getFilename(getConfigurationPath())
    );
  }

  // Date
  else if (name == 'generated-at') {
    writeComment(eComment.Important, ' Gcode generated: ' + value + ' GMT');
  }

  // Document
  else if (name == 'document-path') {
    writeComment(eComment.Important, ' Document: ' + value);
  }

  // Setup
  else if (name == 'job-description') {
    writeComment(eComment.Important, ' Setup: ' + value);
  }

  // Get section comment
  else if (name == 'operation-comment') {
    sectionComment = value;
  } else {
    writeComment(eComment.Debug, ' param: ' + name + ' = ' + value);
  }
}

function onMovement(movement) {
  var jet = tool.isJetTool && tool.isJetTool();
  var id;

  switch (movement) {
    case MOVEMENT_RAPID:
      id = 'MOVEMENT_RAPID';
      break;
    case MOVEMENT_LEAD_IN:
      id = 'MOVEMENT_LEAD_IN';
      break;
    case MOVEMENT_CUTTING:
      id = 'MOVEMENT_CUTTING';
      break;
    case MOVEMENT_LEAD_OUT:
      id = 'MOVEMENT_LEAD_OUT';
      break;
    case MOVEMENT_LINK_TRANSITION:
      id = jet ? 'MOVEMENT_BRIDGING' : 'MOVEMENT_LINK_TRANSITION';
      break;
    case MOVEMENT_LINK_DIRECT:
      id = 'MOVEMENT_LINK_DIRECT';
      break;
    case MOVEMENT_RAMP_HELIX:
      id = jet ? 'MOVEMENT_PIERCE_CIRCULAR' : 'MOVEMENT_RAMP_HELIX';
      break;
    case MOVEMENT_RAMP_PROFILE:
      id = jet ? 'MOVEMENT_PIERCE_PROFILE' : 'MOVEMENT_RAMP_PROFILE';
      break;
    case MOVEMENT_RAMP_ZIG_ZAG:
      id = jet ? 'MOVEMENT_PIERCE_LINEAR' : 'MOVEMENT_RAMP_ZIG_ZAG';
      break;
    case MOVEMENT_RAMP:
      id = 'MOVEMENT_RAMP';
      break;
    case MOVEMENT_PLUNGE:
      id = jet ? 'MOVEMENT_PIERCE' : 'MOVEMENT_PLUNGE';
      break;
    case MOVEMENT_PREDRILL:
      id = 'MOVEMENT_PREDRILL';
      break;
    case MOVEMENT_EXTENDED:
      id = 'MOVEMENT_EXTENDED';
      break;
    case MOVEMENT_REDUCED:
      id = 'MOVEMENT_REDUCED';
      break;
    case MOVEMENT_HIGH_FEED:
      id = 'MOVEMENT_HIGH_FEED';
      break;
    case MOVEMENT_FINISH_CUTTING:
      id = 'MOVEMENT_FINISH_CUTTING';
      break;
  }

  if (id == undefined) {
    id = String(movement);
  }

  writeComment(eComment.Info, ' ' + id);
}

var currentSpindleSpeed = 0;

function setSpindeSpeed(_spindleSpeed, _clockwise) {
  if (currentSpindleSpeed != _spindleSpeed) {
    if (_spindleSpeed > 0) {
      spindleOn(_spindleSpeed, _clockwise);
    } else {
      spindleOff();
    }
    currentSpindleSpeed = _spindleSpeed;
  }
}

function onSpindleSpeed(spindleSpeed) {
  setSpindeSpeed(spindleSpeed, tool.clockwise);
}

function onCommand(command) {
  writeComment(eComment.Info, ' ' + getCommandStringId(command));

  switch (command) {
    case COMMAND_START_SPINDLE:
      onCommand(
        tool.clockwise
          ? COMMAND_SPINDLE_CLOCKWISE
          : COMMAND_SPINDLE_COUNTERCLOCKWISE
      );
      return;
    case COMMAND_SPINDLE_CLOCKWISE:
      if (!tool.isJetTool()) {
        setSpindeSpeed(spindleSpeed, true);
      }
      return;
    case COMMAND_SPINDLE_COUNTERCLOCKWISE:
      if (!tool.isJetTool()) {
        setSpindeSpeed(spindleSpeed, false);
      }
      return;
    case COMMAND_STOP_SPINDLE:
      if (!tool.isJetTool()) {
        setSpindeSpeed(0, true);
      }
      return;
    case COMMAND_COOLANT_ON:
      if (tool.isJetTool()) {
        // F360 doesn't support coolant with jet tools (water jet/laser/plasma) but we've
        // added a parameter to force a coolant to be selected for jet tool operations. Note: tool.coolant
        // is not used as F360 doesn't define it.

        if (properties.coolant != eCoolant.Off) {
          setCoolant(properties.coolant);
        }
      } else {
        setCoolant(tool.coolant);
      }
      return;
    case COMMAND_COOLANT_OFF:
      setCoolant(eCoolant.Off); //COOLANT_DISABLED
      return;
    case COMMAND_LOCK_MULTI_AXIS:
      return;
    case COMMAND_UNLOCK_MULTI_AXIS:
      return;
    case COMMAND_BREAK_CONTROL:
      return;
    case COMMAND_TOOL_MEASURE:
      if (!tool.isJetTool()) {
        probeTool();
      }
      return;
    case COMMAND_STOP:
      writeBlock(mFormat.format(0));
      return;
  }
}

function resetAll() {
  xOutput.reset();
  yOutput.reset();
  zOutput.reset();
  fOutput.reset();
}

function calculateMinMax() {
  var toolZRanges = {};
  var vectorX = new Vector(1, 0, 0);
  var vectorY = new Vector(0, 1, 0);

  var ranges = {
    x: { min: undefined, max: undefined },
    y: { min: undefined, max: undefined },
    z: { min: undefined, max: undefined }
  };

  var handleMinMax = function (pair, range) {
    var rmin = range.getMinimum();
    var rmax = range.getMaximum();
    if (pair.min == undefined || pair.min > rmin) {
      pair.min = rmin;
    }
    if (pair.max == undefined || pair.max < rmin) {
      // was pair.min - changed by DG 1/4/2021
      pair.max = rmax;
    }
  };

  var numberOfSections = getNumberOfSections();
  for (var i = 0; i < numberOfSections; ++i) {
    var section = getSection(i);
    var tool = section.getTool();
    var zRange = section.getGlobalZRange();
    var xRange = section.getGlobalRange(vectorX);
    var yRange = section.getGlobalRange(vectorY);
    handleMinMax(ranges.x, xRange);
    handleMinMax(ranges.y, yRange);
    handleMinMax(ranges.z, zRange);
    if (is3D()) {
      if (toolZRanges[tool.number]) {
        toolZRanges[tool.number].expandToRange(zRange);
      } else {
        toolZRanges[tool.number] = zRange;
      }
    }
  }

  return [ranges, toolZRanges];
}

function writeInformation() {
  const [ranges, toolZRanges] = calculateMinMax();

  // Display the Range Table
  writeComment(eComment.Info, ' ');
  writeComment(eComment.Info, ' Ranges Table:');
  writeComment(
    eComment.Info,
    '   X: Min=' +
      xyzFormat.format(ranges.x.min) +
      ' Max=' +
      xyzFormat.format(ranges.x.max) +
      ' Size=' +
      xyzFormat.format(ranges.x.max - ranges.x.min)
  );
  writeComment(
    eComment.Info,
    '   Y: Min=' +
      xyzFormat.format(ranges.y.min) +
      ' Max=' +
      xyzFormat.format(ranges.y.max) +
      ' Size=' +
      xyzFormat.format(ranges.y.max - ranges.y.min)
  );
  writeComment(
    eComment.Info,
    '   Z: Min=' +
      xyzFormat.format(ranges.z.min) +
      ' Max=' +
      xyzFormat.format(ranges.z.max) +
      ' Size=' +
      xyzFormat.format(ranges.z.max - ranges.z.min)
  );

  // Display the Tools Table
  writeComment(eComment.Info, ' ');
  writeComment(eComment.Info, ' Tools Table:');
  var tools = getToolTable();
  if (tools.getNumberOfTools() > 0) {
    for (var i = 0; i < tools.getNumberOfTools(); ++i) {
      var tool = tools.getTool(i);
      var comment =
        '  T' +
        toolFormat.format(tool.number) +
        ' D=' +
        xyzFormat.format(tool.diameter) +
        ' CR=' +
        xyzFormat.format(tool.cornerRadius);
      if (tool.taperAngle > 0 && tool.taperAngle < Math.PI) {
        comment += ' TAPER=' + taperFormat.format(tool.taperAngle) + 'deg';
      }
      if (toolZRanges[tool.number]) {
        comment +=
          ' - ZMIN=' + xyzFormat.format(toolZRanges[tool.number].getMinimum());
      }
      comment += ' - ' + getToolTypeName(tool.type) + ' ' + tool.comment;
      writeComment(eComment.Info, comment);
    }
  }

  // Display the Feedrate and Scaling Properties
  writeComment(eComment.Info, ' ');
  writeComment(eComment.Info, ' Feedrate and Scaling Properties:');
  writeComment(
    eComment.Info,
    '   Feed: Travel speed X/Y = ' + properties.travelSpeedXY
  );
  writeComment(
    eComment.Info,
    '   Feed: Travel Speed Z = ' + properties.travelSpeedZ
  );
  writeComment(
    eComment.Info,
    '   Feed: Enforce Feedrate = ' + properties.enforceFeedrate
  );
  writeComment(
    eComment.Info,
    '   Feed: Scale Feedrate = ' + properties.scaleFeedrate
  );
  writeComment(
    eComment.Info,
    '   Feed: Max XY Cut Speed = ' + properties.maxCutSpeedXY
  );
  writeComment(
    eComment.Info,
    '   Feed: Max Z Cut Speed = ' + properties.maxCutSpeedZ
  );
  writeComment(
    eComment.Info,
    '   Feed: Max Toolpath Speed = ' + properties.maxCutSpeedXYZ
  );

  // Display the G1->G0 Mapping Properties
  writeComment(eComment.Info, ' ');
  writeComment(eComment.Info, ' G1->G0 Mapping Properties:');
  writeComment(
    eComment.Info,
    '   Map: First G1 -> G0 Rapid = ' + properties.restoreFirstRapids
  );
  writeComment(
    eComment.Info,
    '   Map: G1s -> G0 Rapids = ' + properties.restoreRapids
  );
  writeComment(
    eComment.Info,
    '   Map: SafeZ Mode = ' +
      eSafeZ.prop[safeZMode].name +
      ' : default = ' +
      safeZHeightDefault
  );
  writeComment(
    eComment.Info,
    '   Map: Allow Rapid Z = ' + properties.allowRapidZ
  );

  writeComment(eComment.Info, ' ');
}

function writeFirstSection() {
  // Write out the information block at the beginning of the file
  writeInformation();

  writeComment(eComment.Important, ' *** START begin ***');

  if (properties.gcodeStartFile == '') {
    Start();
  } else {
    loadFile(properties.gcodeStartFile);
  }

  writeComment(eComment.Important, ' *** START end ***');
  writeComment(eComment.Important, ' ');
}

// Output a comment
function writeComment(level, text) {
  if (level <= properties.jobCommentLevel) {
    writeln(';' + String(text).replace(/[\(\)]/g, ''));
  }
}

// Rapid movements with G1 and differentiated travel speeds for XY
// Changes F360 current XY.
// No longer called for general Rapid only for probing, homing, etc.
function rapidMovementsXY(_x, _y) {
  let x = xOutput.format(_x);
  let y = yOutput.format(_y);

  if (x || y) {
    if (pendingRadiusCompensation != RADIUS_COMPENSATION_OFF) {
      error(
        localize(
          'Radius compensation mode cannot be changed at rapid traversal.'
        )
      );
    } else {
      let f = fOutput.format(propertyMmToUnit(properties.travelSpeedXY));
      writeBlock(gMotionModal.format(0), x, y, f);
    }
  }
}

// Rapid movements with G1 and differentiated travel speeds for Z
// Changes F360 current Z
// No longer called for general Rapid only for probing, homing, etc.
function rapidMovementsZ(_z) {
  let z = zOutput.format(_z);

  if (z) {
    if (pendingRadiusCompensation != RADIUS_COMPENSATION_OFF) {
      error(
        localize(
          'Radius compensation mode cannot be changed at rapid traversal.'
        )
      );
    } else {
      let f = fOutput.format(propertyMmToUnit(properties.travelSpeedZ));
      writeBlock(gMotionModal.format(0), z, f);
    }
  }
}

// Rapid movements with G1 uses the max travel rate (xy or z) and then relies on feedrate scaling
function rapidMovements(_x, _y, _z) {
  rapidMovementsZ(_z);
  rapidMovementsXY(_x, _y);
}

// Calculate the feedX, feedY and feedZ components

function limitFeedByXYZComponents(curPos, destPos, feed) {
  if (!properties.scaleFeedrate) return feed;

  var xyz = Vector.diff(destPos, curPos); // Translate the cut so curPos is at 0,0,0
  var dir = xyz.getNormalized(); // Normalize vector to get a direction vector
  var xyzFeed = Vector.product(dir.abs, feed); // Determine the effective x,y,z speed on each axis

  // Get the max speed for each axis
  let xyLimit = propertyMmToUnit(properties.maxCutSpeedXY);
  let zLimit = propertyMmToUnit(properties.maxCutSpeedZ);

  // Normally F360 begins a Section (a milling operation) with a Rapid to move to the beginning of the cut.
  // Rapids use the defined Travel speed and the Post Processor does not depend on the current location.
  // This function must know the current location in order to calculate the actual vector traveled. Without
  // the first Rapid the current location is the same as the desination location, which creates a 0 length
  // vector. A zero length vector is unusable and so a instead the slowest of the xyLimit or zLimit is used.
  //
  // Note: if Map: G1 -> Rapid is enabled in the Properties then if the first operation in a Section is a
  // cut (which it should always be) then it will be converted to a Rapid. This prevents ever getting a zero
  // length vector.
  if (xyz.length == 0) {
    var lesserFeed = xyLimit < zLimit ? xyLimit : zLimit;

    return lesserFeed;
  }

  // Force the speed of each axis to be within limits
  if (xyzFeed.z > zLimit) {
    xyzFeed.multiply(zLimit / xyzFeed.z);
  }

  if (xyzFeed.x > xyLimit) {
    xyzFeed.multiply(xyLimit / xyzFeed.x);
  }

  if (xyzFeed.y > xyLimit) {
    xyzFeed.multiply(xyLimit / xyzFeed.y);
  }

  // Calculate the new feedrate based on the speed allowed on each axis: feedrate = sqrt(x^2 + y^2 + z^2)
  // xyzFeed.length is the same as Math.sqrt((xyzFeed.x * xyzFeed.x) + (xyzFeed.y * xyzFeed.y) + (xyzFeed.z * xyzFeed.z))

  // Limit the new feedrate by the maximum allowable cut speed

  let xyzLimit = propertyMmToUnit(properties.maxCutSpeedXYZ);
  let newFeed = xyzFeed.length > xyzLimit ? xyzLimit : xyzFeed.length;

  if (Math.abs(newFeed - feed) > 0.01) {
    return newFeed;
  } else {
    return feed;
  }
}

// Linear movements
function linearMovements(_x, _y, _z, _feed) {
  if (pendingRadiusCompensation != RADIUS_COMPENSATION_OFF) {
    // ensure that we end at desired position when compensation is turned off
    xOutput.reset();
    yOutput.reset();
  }

  // Force the feedrate to be scaled (if enabled). The feedrate is projected into the
  // x, y, and z axis and each axis is tested to see if it exceeds its defined max. If
  // it does then the speed in all 3 axis is scaled proportionately. The resulting feedrate
  // is then capped at the maximum defined cutrate.

  let feed = limitFeedByXYZComponents(
    getCurrentPosition(),
    new Vector(_x, _y, _z),
    _feed
  );

  let x = xOutput.format(_x);
  let y = yOutput.format(_y);
  let z = zOutput.format(_z);
  let f = fOutput.format(feed);

  if (x || y || z) {
    if (pendingRadiusCompensation != RADIUS_COMPENSATION_OFF) {
      error(localize('Radius compensation mode is not supported.'));
    } else {
      writeBlock(gMotionModal.format(1), x, y, z, f);
    }
  } else if (f) {
    if (getNextRecord().isMotion()) {
      // try not to output feed without motion
      fOutput.reset(); // force feed on next line
    } else {
      writeBlock(gMotionModal.format(1), f);
    }
  }
}

// Test if file exist/can read and load it
function loadFile(_file) {
  var folder = FileSystem.getFolderPath(getOutputPath()) + PATH_SEPARATOR;
  if (FileSystem.isFile(folder + _file)) {
    var txt = loadText(folder + _file, 'utf-8');
    if (txt.length > 0) {
      writeComment(eComment.Info, ' --- Start custom gcode ' + folder + _file);
      write(txt);
      writeComment('eComment.Info,  --- End custom gcode ' + folder + _file);
    }
  } else {
    writeComment(eComment.Important, " Can't open file " + folder + _file);
    error("Can't open file " + folder + _file);
  }
}

function propertyMmToUnit(_v) {
  return _v / (unit == IN ? 25.4 : 1);
}

function Start() {
  // Default
  writeComment(eComment.Info, '   Run Start Macro');
  writeComment(eComment.Info, '   Set Absolute Positioning');
  writeComment(eComment.Info, '   Units = ' + (unit == IN ? 'inch' : 'mm'));
  // writeComment(eComment.Info, "   Disable stepper timeout");

  if (properties.initializeOriginAtStart) {
    writeComment(eComment.Info, '   Set current position to 0,0,0');
  }

  if (properties.beginMacro) {
    writeBlock(properties.beginMacro);
  }

  writeBlock(gAbsIncModal.format(90)); // Set to Absolute Positioning
  writeBlock(gUnitModal.format(unit == IN ? 20 : 21)); // Set the units
  // writeBlock(mFormat.format(84), sFormat.format(0)); // Disable steppers timeout

  if (properties.initializeOriginAtStart) {
    writeBlock(
      gFormat.format(92),
      xFormat.format(0),
      yFormat.format(0),
      zFormat.format(0)
    ); // Set origin to initial position
  }

  if (properties.probeAtStart && tool.number != 0 && !tool.isJetTool()) {
    onCommand(COMMAND_TOOL_MEASURE);
  }

  if (properties.frameAtStart) {
    // xyzFormat.format(ranges.x.min)
    const [ranges, toolZRanges] = calculateMinMax();
    var loops = properties.frameLoops;

    writeComment(
      eComment.Info,
      '   Pause to allow manual Z height adjustments'
    );
    display_text(
      'Manually ensure Z height is safe before framing movements, then resume'
    );
    writeBlock('PAUSE');
    writeComment(eComment.Info, '   Perform Framing Loops: ');

    for (var i = 0; i < loops; i++) {
      rapidMovementsXY(ranges.x.min, ranges.y.min);
      onDwell(1);

      rapidMovementsXY(ranges.x.max, ranges.y.min);
      onDwell(1);

      rapidMovementsXY(ranges.x.max, ranges.y.max);
      onDwell(1);

      rapidMovementsXY(ranges.x.max, ranges.y.min);
      onDwell(1);
    }

    if (properties.pauseAfterFrame) {
      writeComment(eComment.Info, '   Pausing after framing loops');
      writeBlock('PAUSE');
    }
    writeComment(eComment.Info, '   Finished Framing Loops');
  }
}

function end() {
  // Default
  if (properties.endMacro) {
    writeBlock(properties.endMacro);
  }
  display_text('Job end');
}

function spindleOn(_spindleSpeed, _clockwise) {
  // Default
  if (properties.manualSpindlePowerControl) {
    // For manual any positive input speed assumed as enabled. so it's just a flag
    if (!this.spindleEnabled) {
      writeComment(eComment.Important, ' >>> Spindle Speed: Manual');
      messageThenPause(
        'Turn ON ' + speedFormat.format(_spindleSpeed) + 'RPM',
        'Spindle',
        false
      );
    }
  } else {
    writeComment(
      eComment.Important,
      ' >>> Spindle Speed ' + speedFormat.format(_spindleSpeed)
    );
    writeBlock(
      mFormat.format(_clockwise ? 3 : 4),
      sOutput.format(spindleSpeed)
    );
  }
  this.spindleEnabled = true;
}

function spindleOff() {
  //Default

  if (properties.manualSpindlePowerControl) {
    writeBlock(mFormat.format(300), sFormat.format(300), pFormat.format(3000));
    messageThenPause('Turn OFF spindle', 'Spindle', false);
  } else {
    writeBlock(mFormat.format(5));
  }
  this.spindleEnabled = false;
}

function display_text(txt) {
  // Default - Update display
  writeBlock(
    mFormat.format(117),
    (properties.separateWordsWithSpace ? '' : ' ') + txt
  );

  // Also write message in console
  writeBlock(
    mFormat.format(118),
    (properties.separateWordsWithSpace ? '' : ' ') + txt
  );
}

function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
  if (isHelical()) {
    linearize(tolerance);
    return;
  }
  if (!getProperty("allowArcs")) {
    linearize(tolerance);
    return;
  }
  var start = getCurrentPosition();
  gMotionModal.reset();
  switch (getCircularPlane()) {
  case PLANE_XY:
    writeBlock(gPlaneModal.format(17), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x), jOutput.format(cy - start.y), feedOutput.format(feed));
    break;
  case PLANE_ZX:
    writeBlock(gPlaneModal.format(18), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x), kOutput.format(cz - start.z), feedOutput.format(feed));
    break;
  case PLANE_YZ:
    writeBlock(gPlaneModal.format(19), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), jOutput.format(cy - start.y), kOutput.format(cz - start.z), feedOutput.format(feed));
    break;
  default:
    linearize(tolerance);
  }
}

function messageThenPause(text, title, allowJog) {
  // Default
  writeBlock(
    mFormat.format(117),
    (properties.separateWordsWithSpace ? '' : ' ') + text
  );
  writeBlock(
    mFormat.format(118),
    (properties.separateWordsWithSpace ? '' : ' ') + text
  );
  writeBlock('PAUSE');
}

function toolChange() {
  // Default tool change
  flushMotions();

  // Go to tool change position
  onRapid(
    propertyMmToUnit(properties.toolChangeX),
    propertyMmToUnit(properties.toolChangeY),
    propertyMmToUnit(properties.toolChangeZ)
  );

  flushMotions();

  // turn off spindle and coolant
  onCommand(COMMAND_COOLANT_OFF);
  onCommand(COMMAND_STOP_SPINDLE);
  if (!properties.manualSpindlePowerControl) {
    // Beep
    writeBlock(mFormat.format(300), sFormat.format(400), pFormat.format(2000));
  }

  // Disable Z stepper
  if (properties.toolChangeDisableZStepper) {
    messageThenPause(
      'Z Stepper will disabled. Wait for STOP!!',
      'Tool change',
      false
    );
    writeBlock(mFormat.format(17), 'Z'); // Disable steppers timeout
  }
  // Ask tool change and wait user to touch lcd button
  messageThenPause(
    'Tool ' + tool.number + ' ' + tool.comment,
    'Tool change',
    true
  );

  // Run Z probe gcode
  if (properties.probeAfterToolChange && tool.number != 0) {
    onCommand(COMMAND_TOOL_MEASURE);
  }
}

function probeTool() {
  // Default
  writeComment(eComment.Important, ' Probe to Zero Z');
  writeComment(eComment.Info, '   Ask User to Attach the Z Probe');
  writeComment(eComment.Info, '   Do Probing');
  writeComment(
    eComment.Info,
    '   Set Z to probe thickness: ' +
      zFormat.format(propertyMmToUnit(properties.probeThickness))
  );
  if (properties.toolChangeZ != '') {
    writeComment(
      eComment.Info,
      '   Retract the tool to ' + propertyMmToUnit(properties.toolChangeZ)
    );
  }
  writeComment(eComment.Info, '   Ask User to Remove the Z Probe');

  messageThenPause('Attach ZProbe', 'Probe', false);
  // refer http://marlinfw.org/docs/gcode/G038.html
  if (properties.probeHomeZ) {
    writeBlock(gFormat.format(28), 'Z');
  } else {
    writeBlock(
      gMotionModal.format(38.3),
      fFormat.format(propertyMmToUnit(properties.probeG38Speed)),
      zFormat.format(propertyMmToUnit(properties.probeG38Target))
    );
  }

  let z = zFormat.format(propertyMmToUnit(properties.probeThickness));
  writeBlock(gFormat.format(92), z); // Set origin to initial position

  resetAll();
  if (properties.toolChangeZ != '') {
    // move up tool to safe height again after probing
    rapidMovementsZ(propertyMmToUnit(properties.toolChangeZ), false);
  }

  flushMotions();
  messageThenPause('Detach ZProbe', 'Probe', false);
}
