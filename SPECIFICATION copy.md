#UXML Language Specification

##Abstract

This specification defines the features and syntax of UXML, a mark-up language for media-rich and animated documents for touch-enabled devices.

##Status of this document

This specification describes the current snapshot of the UXML 0.1, which is still under development and may change drastically.

##Introduction

UXML is a declarative language for create media-rich documents (books and presentations) that contains photos, videos, vector graphics, animations, voices, music and sound effects, which will be consumed on touch-enabled devices (such as smartphones, tablets and touch-enabled set-top-boxes).

Previous approaches require "procedural programming", which can be done only by skilled developers and are very expensive, error-prone and time-consuming.

The declarative nature of UXML language (and the lack of "procedural programming environment") makes very easy to learn, write and read. It also makes it easy to auto-generate documents (from data) and create authoring environments.

### Scope

UXML was designed for a specific set of applications and contents.

- Signage
- Graphical Audio Books
- Photo & Video Books
- Graphical Music Albums
- Media-rich Presentations
- Video Instructions & Tutorials

UXML is NOT

- A general-purpose programming environment where programmers write procedural code
- A game engine

### Design Principles

- Declarative
- JSON instead of XML
- Lightweight

### Data Types

- **String**: Regular string
- **Color**: One of RBG(A) styles ("#RRGGBB", "#RGB", "#RRGGBBAA", "#RGBA") or, one of standard color names ("red", "black", "blue", "white", "green", "yellow", "purple", "gray", "darkGray", "lightGray", "brown", "orange", "cyan", "magenta")
- **Percent**: "NN%" relative to the parent
- **Path**: SVG-style Path String
- **URL**: relative or absolute URL
- **StringId**: Regular string used as an identifier
- **LangId**: Language identifier, such as "\*", "en", "ja", "de", etc., where "\*" represents the default

## Document

A **Document** is a UTF8 JSON file, which consists of a collection of **Pages**. The order of **Pages** in the collection is not significant.

Here is a sample **Document** which consists of two pages:

```
{
	"pages": [
		{
			"elements": [
				{ "text":"Hello World!" }
			]
		},
		{
			"elements": [
				{ "text":"Good Bye!" }
			]
		}
	]
}
```

When this document with a UXML viewer, the user will see only the first page with text "Hello World!" in the middle of screen.

### Document Properties

- **type** (String): This must be "net.swipe.swipe" for a UXML document
- **title** (String): Title of the document, optional
- **bc** (Color): Background color, default is *darkGray*
- **dimension** ([Int, Int]): Dimension of the document, default is [320, 568]
- **paging** (String): Paging direction, *vertical* (default), or *leftToRight*
- **orientation** (String): Document orientation, *portrait* (default) or *landscape*
- **resources** ([String,...]): Resource keys for on-demand resources
- **viewstate** (Bool): Indicate if we need to save&restore view state. The default is true.
- **languages** ({"id":LangId, "title":String},...): Languages to display via the "Lang." button in the UXML viewer.
- **data** ({"Source":URL, "format":DataFormat})
- **paths** ({Name:Path}): **Paths** dictionary
- **markdown** ({Name:Style}): **Markdown** style
- **voices** ({Name:VoiceInfo}): **Voice** style
- **templates**
 - **pages** ({Name:PageTemplate}): **PageTemplate** dictionary
 - **elements** ({Name:ElementTemplate}):	 **ElementTemplate** dictionary
- **pages** ([Page,...]): Collection of **Pages**

```
{
	"data": {
		data1": {
			"source": "http://domain.com/data.json",
			"format" {
				"name": [ "first",	"last" ],
				"address : [ "street", "city", "state", "Zip" ]
			}
		}
	},
	"styles": [
		{
			"name": "style1",
			"source": "http://domain.com/style.json",
			"defaults": {
				"font1": { "color":"#008", "font":{ "size":"5%", "name":["foo", "Courier"] }},
			}
		}			
	},
	"pages": [
		{
			"elements": [
				{ "text": ["data1", "name", "first" ] },
			],
		},
	]
}
```

## Page

**Page** consists of a collection of **Elements**. The order of **Elements** in the collection is significant, those elements will be rendered in the specified order (from bottom to top).

Here is a **Document** with a **Page**, which has two **Elements**.

```
{
	"pages": [
		{
			"elements": [
				{ "x":50, "y":100, "w":100, "h":100, "bc":"red" },
				{ "x":100, "y":150, "w":100, "h":100, "bc":"blue" },
			]
		},
	]
}
```

### Page Properties

- **bc** (Color): Background color, the default is *white*
- **fpt** (Int): Frame per second, the default is 60
- **transition** (String): Inter-page transition style, *scroll* (default), *fadeIn* or *replace*
- **duration** (Float): Duration of the animation in seconds, the default is 0.2 seconds
- **repeat** (Boolean): Repeat rule of the animation, default is *false*
- **rewind** (Boolean): Rewind rule of the animation when the user leaves the page, default is *false*
- **template** (String): Name of the *PageTemplate*, default is "\*"
- **elements** ([Element+]): Collection of Elements
- **eyePosition** (Float): Eye position (z-height) for the perspective relative to width, default is 1.0
- **strings** ([StringId:[LangId:String]]): String resources

## Paging direction and inter-page transition

The paging direction is defined by the "paging" property of the **Document**. It must be either *vertical*, *leftToRight* or *rightToLeft*, and the default is *vertical*.

### Values for the "transition" property

- *scroll*: regular scrolling behavior (default)
- *fadeIn*: The preceding **Page** will fade-in while the user drags it in.
- *replace*: The preceding **Page** will replace when the user start dragging.

## PageTemplate

A **PageTemplate** defines a set of properties and **Elements** to be shared among multiple **Pages**.

A **Page** is always associated with a **PageTemplate**, either explicitly with the "template" property or implicitly with the default **pageTemplate** with name "*".

The **Page** inherits all the properties from the associated **PageTemplate**, including **Elements**. When the same property is specified both in the **Page** and the **PageTemplate**, the value specified in the **Page** will be used. The only exception to this rule is **Elements**, which will be deep-merged (deep-inheritance). **Elements** with the *id* property will be merged, and other **Elements** will be appended (**Elements** defined in the **PageTemplate** are always placed below **Elements** specified in the **Page**).

Here is a **Document** with two **Pages**, where the first **Page** is associated with the default **PageTemplate**, and the second **Page** is associated with the "alternative" **PageTemplate**. Because each **PageTemplate** specifies the background color, those **Pages** inherit those background colors.	 

```
{
	"templates": {
		"pages": {
			"*": { "bc":"blue" },
			"alternative": { "bc":"green" }
		}
	}
	"pages": [
		{
			"elements": [
				{ "text":"Hello World!" }
			]
		},
		{
			"template":"alternative",
			"elements": [
				{ "text":"Good Bye!" }
			]
		}
	]
}
```

The following example uses the "id" to identify a particular **Element** in the **PageTemplate** and modify its "textColor" property.

```
{
	"templates": {
		"pages": {
			"*": {
				"elements": [
					{ "id":"hello", "text":"Hello World" }
				]
			}
		}
	},
	"pages": [
		{
			"elements": [
				{ "id":"hello", "textColor":"red" }
			]
		},
		{
			"elements": [
				{ "id":"hello", "textColor":"green" }
			]
		},
	]
}
```

## Element

An **Element** is a visible entity on a **Page**. It occupies a specified rectangle area within a **Page**. An **Element** may contain child **Elements**.

### Element properties

- **id** (String): the element identifier in the associated **ElementTemplate** at the same nesting level
- **template** (String): the name of the **ElementTemplate** to inherit properties from
- **x** (Float or Percent): x-position of the left-top corner of element, default is 0
- **y** (Float or Percent): y-position of the left-top corner of the element, default is 0
- **pos** ([Float/Percent, Float/Percent]): alternative way to specify the position by the location of the anchor point
- **anchor** ([Float/Percent, Float/Percent]): anchor point, default is ["50%", "50%"]
- **w** (Float, Percent or "fill"): width of the element, default is "100%".
- **h** (Float, Percent or "fill"): height of the element, default is "100%"
- **bc** (Color): background color, default is *clear*, animatable
- **clip** (Boolean): Specifies clipping behavior, default is false
- **borderWidth** (Float): Width of the border, default is 0, animatable
- **borderColor** (Color): Color of the border, animatable
- **cornerRadius** (Float): Size of the corner radius, animatable
- **opacity** (Float): Opacity of the element, between 0 to 1, animatable
- **rotate** (Float or Float[3]): Rotation in degree around the anchor point, clockwise, default is 0, animatable.
- **scale** (Float or [Float, Float]): Scaling factor around the anchor point, default is [1, 1], animatable
- **translate** ([Float, Float]): Translation, default is [0, 0], animatable
- **text** (String, [langId:String] or ["ref":StringId]): Text to display
  - **textAlign** (String): Text alignment, *center* (default), *left* or *right*
  - **fontSize** (Float or Percent): Font size
  - **fontName** (String or [String]): Font name or names (the first name existing in the system is used)
  - **textColor** (Color): Color of the text, animatable
- **markdown** (String or [String]): Markdown to display
- **img** (URL): Image to display, animatable
- **mask** (URL): Image mask (PNG with the alpha channel)
- **sprite** (URL): Sprite to display
	- **slice** ([Int, Int]): Dimension of the sprite
	- **slot** ([Int, Int]): Slot to display, animatable
- **path** (Path): Path to display (SVG style), animatable
	- **lineWidth** (Float): Width of stroke, default is 0
	- **strokeColor** (Color): Color of the stroke, default is black, animatable
	- **fillColor** (Color): Fill color, default is clear, animatable
	- **strokeStart** (Float): Starting offset, default is 0, animatable
	- **strokeEnd** (Float): Ending offset, default is 1, animatable
- **video** or **radio** (URL): Video/Radio to play
	- **videoStart** (Float): Starting point of the video in seconds, default is 0
	- **videoDuration** (Float): Ending point of the video in seconds
- **stream** (Bool): Specifies if the resource specified with the video tag is stream or not, default is false
- **to** (Transition Animation): Specifies the Transitional Animation
- **loop** (Loop Animation): Specifies the Loop Animation
- **tiling** (Bool): Specifies the tiling (to be used with *shift* loop animation)
- **action** (String): Specifies the Action
- **repeat** (Bool): Repeat rule for the element. The default is false.

## ElementTemplate

**Element Template**s are a set of **Elements** defined in "elementTemplates" property of the **Document**. Any **Element** can inherit properties from **Element Template**s by specifying its name in the *template* property.

The sample below uses a **Element Template** named "smile" for five different **Elements** in a page.

```
{
	"templates": {
		"elements": {
			"smile": {
				"lineWidth":3,
				"path":"M0,0 C10,50 90,50 100,0",
				"strokeColor":"red"
			}
		}
	},
	"pages": [
		{
			"elements": [
				{ "template":"smile", "pos":["50%", 100] },
				{ "template":"smile", "pos":["50%", 200], "rotate":30 },
				{ "template":"smile", "pos":["50%", 300], "lineWidth":10 },
				{ "template":"smile", "pos":["50%", 400], "strokeColor":"#37F" },
				{ "template":"smile", "pos":["50%", 500], "scale":[2,1] },
			],
		},
	]
}
```

Just like a regular **Element**, a	**ElementTemplate** may have child **Elements**, and they will be deep-merged just like **Elements** in a **PageTemplate**.

The following example shows how to use an **ElementTemplate** with child **Elements**, and override their properties using the "id" property.

```
{
	"templates": {
		"elements":{
			"helloWorld": {
				"w":160, "h":100,
				"elements": [
					{ "id":"hello", "text":"Hello", "textAlign":"left" },
					{ "id":"world", "text":"World", "textAlign":"left", "x":80 },
				},
			},
		},
	},
	"pages": [
		{
			"elements": [
				{ "template":"helloWorld", "pos":[160, 100] },
				{ "template":"helloWorld", "pos":[160, 200],
					"elements":[
					{ "id":"hello", "textColor":"red", },
					{ "id":"world", "textColor":"blue", },
					]},
				{ "template":"helloWorld", "pos":[160, 300],
					"elements":[
					{ "id":"world", "text":"UXML!" },
					]},
			],
		},
	]
}
```

## Animation

Specifies a set of animations to play.

The "animation" property of each element specifies the animation to be performed on the element, by specifying a new value for animatable properties (such as "opacity", "rotate", "translate", "bc", "path", "pos", "mode").

The "timing" property specifies the timing of animation with two floating values, start and end (must be between 0.0 and 1.0). The default is [0.0, 1.0].

```
{
	"templates": {
		"elements": {
			"button": {
				"text:"button",
				"elements": [
					{ "w":50 "h":20 "bc":"#ddd" }
				],
				"events: {
					"tapped":[
						{
							"animate": { "bc":"#ccc"}, "duration":.2},
							"events": {
								"completion": { "animate": { "bc":"#dddd"}, "duration":.2}
							}
						}
					],
					"focus": [
						...
					]
				}
			}
		}
	},
	"pages": [
		{
			"name":"page1",
			"elements": [
				{ "name": "hello", "text": "Hello World!" },
				{
					"template": "button",
					"text:"<",
					"events: {
						"tapped":[
							{ "update": { "hello": "hello" } },
						]
					}
				}
			]
		}
	]
}
```

the duration of the animation is determined by the "duration" property of the page (the default is 0.2 seconds).

```
{
	"pages": [
		{
			"elements": [
				{ "text":"Hello World!" }
			]
		},
		{
			"play":"scroll",
			"elements": [
				{ "text":"Hello World!", "to":{ "translate":[0, 200] } }
			]
		}
	]
}
```

## Loop Animation

The "loop" property of the element specifies the **Loop Animation** associated with the element. Unlike **Transition Animation**, it repeats the same animation multiple times specified by the *count* property (the default is 1).

The **Loop Animation** must have a "style" property, and the value of this property must be one of following.

- *vibrate*: The **Element** vibrates left to right, where the "delta" property specifies the distance (the default is 10)
- *blink*: The **Element** blinks changing its opacity from 1 to 0.
- *wiggle*: The **Element** rotates left and right, where the "delta" property specifies the angle in degree (the default is 15)
- *spin*: The **Element** spins, where the "clockwise" property (boolean) specifies the direction, the default is true.
- *shift*: The **Element** shift to the specified direction where the "direction" property specifies the direction ("n", "s", "e" or "w", the default is "s"). Use it with the "tiling" property.
- *path*: The **Element** performs path animation, where the "path" property specifies a collection of **Paths**.
- *sprite*: The **Element** performs a sprite animation.

Following example wiggles the text "I'm wiggling!" three times when the second page appears on the screen.

```
{
	"pages": [
		{
			"elements": [
				{ "text":"Hello World!" }
			]
		},
		{
			"elements": [
				{ "text":"I'm wiggling!", "loop":{ "style":"wiggle", "count":3 } }
			]
		}
	]
}
```

## Completion

```
{
	"elementTemplates": {
		"button": {
			"text:"button",
			"elements": [
				{
					"name":"bg",
					"w":50,
					"h":20,
					"bc":"#ddd",
					"events: [
						{
							"on": ["tapped", "click"],
							"actions": [
								"animate": {
									"name": "bg",
									"bc":"#ccc",
									"duration":0.2,
									"completionActions": [
										{ "animate": { "name": "button", "alpha":0, "duration":.2 }
										{ "segue": { "page": "page2", "style":"fadeIn", "duration":.2 } }
									]
								}
							]
						},
					],
				},
			],
		},
	},
	"pages": [
		...
	]
}
```

## Timers
```
{
	"templates": {
		"elements": {
			"t1": {
				"text": "t1",
				"events": {
					"tapped": [
						{
							"update": {"text":"text1 tapped"}
						},
						{
							"timer": {
								"duration":0.5,
								"events": {
									"tick": [
										{
											"update": {"text":"hello"}
										}
									]
								}
							}
						}
					]
				}
			}
		}
	}
}
```

## Segues

```
{
	"pages": [
		{
			"name":"page1",
			"elements": [
				{
					"name": "button",
					"text:"Go to Page 2",
					"elements": [
						{
							"name":"bg",
							"w":50,
							"h":20,
							"bc":"#ddd",
							"events: [
								{
									"on": ["tapped"],
									"do": [
										"animate": {
											"name": "bg",
											"bc":"#ccc",
											"duration":0.2,
											"events": [
												{
													"on":["completion"],
													"do": [
														{ "animate": { "name": "button", "alpha":0, "duration":.2 } }
														{ "segue": { "page": "page2", "style":"fadeIn", "duration":.2 } }
													]
												}
											]
										}
									]
								},
								{
									"on": ["doubleTap"],
									"do": [
										"animate": {
											"name": "bg",
											"bc":"#fcc",
											"duration":0.2,
											"actions": [												
												{ "animate": { "name": "button", "alpha":0, "duration":.2 } }
												{
													"timer": {
														"duration":.2,
														"actions": [
															{ "segue": { "page": "page2", "style":"fadeIn", "duration":.2 } }
														]
													}
												}
											]
										}
									]
								}
							],
						},
					],
				}
			]
		},
		{
			"name":"page2",
			"elements": [
			]
		},
	]
}
```

## Sounds

- **audio** (URL): Specifies the sound effect to be played
- **speech** (SpeechInfo): Specifies the text-to-speech to be played
- **vibrate** (VibrationInfo): Specifies the vibration in sync with the animation

## Text Input

```
{
	"pages": [
		{
			"name":"main",
			"elements": [
				"name": "input",
				"textEdit": { "value":"hello", "prompt":"greeting", "attributes":"alphanumeric" | "numeric" | ... },
				"events": [
					{
						"on": ["textReturn"], "params": { "text": "string" } }, "do": [
							{
								"send":"http://mydomain.com/changed",
								"params":{ "p1":"v1", "p2":"v2", ... },
								"data":{"text": "params.text" },
								"events": [
									{
										"on": ["error"], "params": {...}, "do": [...]
									},
									{
										"on": ["completion"],
										"params": {
													"code": { "type": "number" },
													"response": {"type":"string"}
												}
										},
										"do": [
											{ "update":"input", "value":"params.response.text" }
										]
									}
								]
							}
					}
				]
			]
		}
	]
}
```

## List Element

```
{
	"pages": [
		{
			"name": "main",
			"elements": [
				{
					"name": "aList",
					"h":"80%",
					"bc":"#eef",
					"list": {
						"rowTemplates": {
							"odd": {
								"bc":"#eef",
								"elements": [
									{ "name":"icon", "w":"20%", "img":{"items":"img"} },
									{ "name":"label", "x":"20%", "w":"80%", "text":{"items":{"person":"first"}}, "textAlign":"left" }
								]
							},
							"even": {
								"bc":"#efe",
								"elements": [
									{ "name":"label", "w":"80%", "text":{"items":{"person":"first"}}, "textAlign":"right" }
									{ "name":"icon", "x":"80%", "w":"20%", "img":{"items":"img"} },
								],
              }
            },
						"items": [
							{ "img":"http://domain/images/man.png", "person": { "first":"fred", "last":"flintstone"}},
							{ "img":"http://domain/images/woman.png", "person": { "first":"wilma", "last":"flintstone"}},
							{ "img":"http://domain/images/girl.png", "person": { "first":"pebbles", "last":"flintstone"}},
							{ "img":"http://domain/images/man.png", "person": { "first":"barney", "last":"rubble"}},
							{ "img":"http://domain/images/woman.png", "person": { "first":"betty", "last":"rubble"}},
							{ "img":"http://domain/images/boy.png", "person": { "first":"bambam", "last":"rubble"}},
						]
					}
				}
			]
		}
	]
}
```

```
{
	"data": {
		"urls": [
			"http://domain/images/man.png",
			"http://domain/images/woman.png",
			"http://domain/images/girl.png",
			"http://domain/images/boy.png",
		],
		"families": [
			{ "code":0, "person": { "first":"fred", "last":"flintstone"}},
			{ "code":1, "person": { "first":"wilma", "last":"flintstone"}},
			{ "code":2, "person": { "first":"pebbles", "last":"flintstone"}},
			{ "code":0, "person": { "first":"barney", "last":"rubble"}},
			{ "code":1, "person": { "first":"betty", "last":"rubble"}},
			{ "code":3, "person": { "first":"bambam", "last":"rubble"}},
		]
	},
	"pages": [
		{
			"name": "main",
			"elements": [
				{
					"name": "aList",
					"list": {
						rowTemplates: {
							"odd": {
								"bc":"#eef",
								"elements": [
									{ "name":"icon", "w":"20%", "img":{"urls":{families":"code"}} },
									{ "name":"label", "x":"20%", "w":"80%", "text":{families":{"person":"first"}}, "textAlign":"left" }
								]
							},
							"even": {
								"bc":"#efe",
								"elements": [
									{ "name":"label", "w":"80%", "text":{families":{"person":"first"}}, "textAlign":"right" }
									{ "name":"icon", "x":"80%", "w":"20%", "img":{"urls":{ families":"code"}} },
								]
							}
						}
					}
				}
			]
		}
	]
}
```

## Variables

```
{
	"variables": {
		{ "aNumber":{"type":"number", value:10 },
		{ "aString":{"type":"string", value:"hello" },
		{ "anArray":{"type":"array", "items": {"type":"string", values:["hello", "world"]}}}
	},
	"pages": [
		{
			"name":"main",
			"elements": [
				{
					"text":{"variable":"aString"}
				}
			]
		}
	]
}
```

## Actions

```
{
	"templates": {
		"actions": {
			"action1": { "update": { "x":20 } }
		}
	},
	"pages": [
		{
			"events": {
				"tapped": [
					"template": "action1"
				]
			}
		}
	]
}
```

## Server Interaction

Page Params


```
{
	"pages": [
		{
			"name":"main",
			"elements": [
				{
					"text": "hello",
					"events": [
						{
							"on": ["tapped"], "do": [ { "segue": { "page": "pageWithParams", "params: { "text":"world" }, "style":"fadeIn", "duration":.2 } } ]
						}
					]
				}
			]
		},
		{
			"name":"pageWithParams",
			"params": { "text": {"type":"string", "default":"****"} },
			"elements": [
				{ "text":{"params":{"text"}} }
			]
		}
	]
}
```

Send/Receive Data

- via HTTP POST JSON

```
{
	"pages": [
		{
			"name": "fetchPage",
			"elements": [
				{"name":"label", "text":"Loading ...", "h":40, "pos":["50%", 40], "opacity":0.1, "to": { "opacity":1} },
				{"name":"error", "text":"<error>", "textColor":"red", "h":40, "pos":["50%", 82], "opacity":0 },
			 ],
			"events": [
				{
					"load": [
						{
							"fetch":{
								"source":"http://domain.com/data.json",
								"params":{ "p1":"v1", "p2":"v2" },
								"events": {
									"error": {
										"params": {"code":{"type":"number"}, "message":{"type":"string"}},
										"actions": [
											{ "update":{"name":"error", "value":{"params":"message"}, "to":{ "opacity":1 }}}
										]
									},
									"completion": {
										"params": {"code":{"type":"number"}, "message":{"type":"string"}},
										"actions": [
											{ "update":{"name":"label", "value":{"params":"message"}}}
										]
									}
								}
							}
						}
					]
				}
			]
		}
	]
}
```
```
{
	"data": {
		"urls": [
			"http://domain/images/father.png",
			"http://domain/images/monther.png",
			"http://domain/images/daughter.png",
			"http://domain/images/son.png",
		],
	},
	"schema": {
		"families": [
			{ "code":"number", "person": { "first":"string", "last":"string"} },
		]
	}
	"pages": [
		{
			"name": "main",
			"elements": [
				{
					"name": "aList",
					"list": {
						rowTemplates: {
							"odd": {
								"bc":"#eef",
								"elements": [
									{ "name":"icon", "w":"20%", "img":{ "urls":{ families":"code" } } },
									{ "name":"label", "x":"20%", "w":"80%", "text":{ families":{ "person":"first" } }, "textAlign":"left" }
								]
							},
							"even": {
								"bc":"#efe",
								"elements": [
									{ "name":"label", "w":"80%", "text":{ families":{ "person":"first" } }, "textAlign":"right" }
									{ "name":"icon", "x":"80%", "w":"20%", "img":{ "urls":{ families":"code" } } },
								]
							}
						}
					},
					{ "name":"error", "text":"<error>", "textColor":"red", "h":40, "pos":["50%", 82], "opacity":0 },
				}
			],
			"events": {
				"load": {
					"actions": [
						{
							"fetch":{
								"source":"http://domain.com/families.json",
								"params":{ "p1":"v1", "p2":"v2" },
								"events": {
									"error": {
										"params": {"code":{"type":"number"}, "message":{"type":"string"}},
										"actions": [{ "update":{"name":"error", "value":{"params":"message"}, "to":{"opacity":1}} }]
									},
									"completion": {
										"params": {"code":{"type":"number"}, "response":{"schema":"families"}},
										"actions": [{ "update":{"name":"aList", "items":{"params":"response"}} }]
									}
								}
							}
						]
					}
				}
			}
		}
	]
}
```

## Styles

## Multilingual Strings

The "strings" property of the page specifies strings in multiple languages.	 The format is:

```
	"strings": {StringId: {LangId:String, ...}}
```

"text" elements on the page can specify the string via the "strings" property which has the format:
```
	"text":{"strings":StringId}
```

Following example displays "good day" and "good evening" unless the locale is "de"; then "Guten Tag" and "guten Abend" are displayed.

```
{
	"pages":[
		{
			"strings": {
				"good day": {"*":"good day", "de": "Guten Tag"},
				"good evening": {"*":"good evening", "de": "guten Abend"},
			},

			"elements":[
				{ "text":{"strings":"good day"}, "h":"20%", "pos":["50%", "12%"]},
				{ "text":{"strings":"good evening"}, "h":"20%", "pos":["50%", "34%"]},
			],
		}
	]
}
```

Alternatively, the "text" element can directly specify the strings for each language directly using the following format:
```
	"text":{ LangId:String, ...}
```

Following example displays "good morning" and "good afternoon" unless the locale is "de"; then "guten Morgen" and "guten Nachmittag" are displayed.

```
{
	"pages":[
		{
			"elements":[
				{ "text":{"*":"good morning", "de": "guten Morgen"}, "h":"20%", "pos":["50%", "12%"]},
				{ "text":{"*":"good afternoon", "de": "guten Nachmittag"}, "h":"20%", "pos":["50%", "34%"]},
			]
		}
	]
}
```

To enable language selection in the UXML viewer via the "Lang." button, use the **Document** property **languages** to list the available languages using the following format:

```
	"languages":[{"name":LangId, "title":String},...]
```

Example:

```
{
	"languages":[
		{"id": "en", "title": "English"},
		{"id": "de", "title": "German"},
	],
	"pages":[
		{
			"elements":[
				{ "text":{"*":"good morning", "de": "guten Morgen"}, "h":"20%", "pos":["50%", "12%"]},
				{ "text":{"*":"good afternoon", "de": "guten Nachmittag"}, "h":"20%", "pos":["50%", "34%"]},
			],
		}
	]
}
<<<<<<< HEAD
=======

>>>>>>> swipe-org/master
```
