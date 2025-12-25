# MyScript Interactive Ink iOS Documentation

*Scraped from https://developer.myscript.com/docs/interactive-ink/4.2/*

---

## Introduction

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/concepts/introduction/*

Introduction 

Welcome!

If you are not yet familiar with MyScript technology, it is worth taking a few minutes to get to know our core concepts. MyScript technology is a powerful way to interpret handwritten input to inject ink into your digital workflow. This section explains the key concepts behind it as well as the ink interaction patterns that will let you make the most of it!

MyScript technology performs handwriting recognition with digital ink as input.
To get a better overview of how it works, feel free to consult the page dedicated to our AI technology

Digital ink has many advantages over its analog counterpart. It can be archived, shared, synchronized across devices and even searched, thanks to handwriting recognition. But, it falls short when it comes to deeply integrate with digital workflows. This is where interactivity enters the scene as we factored our UX expertise and years of experience into a logical, efficient concept that we call interactive ink.

---

## OCR vs digital ink recognition

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/concepts/digital-ink-vs-ocr/*

OCR vs digital ink recognition 

Before going any further, it is important to make the difference between digital ink and optical character recognitions.

Suppose you write something on a screen or a sheet of paper that you want to recognize. You, first, need to represent this ink so that it is suitable for computer processing. There are two common approaches for this: optical character and digital ink recognition.

## Optical Character Recognition (OCR)

Scanning a written page with an optical scanner or a camera produces a bitmap image, that is to say an array of pixels. Each pixel represents a part of what was captured.
OCR applications then use image analysis to extract text or shape information from this data. They rely on a visual representation of ink.

“hello”Bitmap imageRecognitionScan orpicture 

So they must segment handwriting or typeset from other information contained by the paper. This may lead OCR to confusion and errors.

## Digital ink recognition

Digital ink recognition systems analyze 2D points sequences. Those points describe ink trajectories and are produced by various devices or systems, as:

- Finger touch or stylus on a screen.
- Digital pen and paper.
- Vectorization of a bitmap (although this is pretty difficult to get right)

“hello”Digital inkRecognitionCapture 

Collected digital ink thus expresses the trajectory of handwritten strokes.

A stroke is the trajectory of a finger or stylus, from the moment it touches the writing area (pen down) until it goes upwards (pen up). It might include information about the pressure used to write as well.

Thus, a sequence of pen events models the stroke. The first event corresponds to a down event. The last one is a up event, and all other ones are move events. Each event also contains spatial and temporal information: (x, y, t, P) . x and y are the pen position, t the absolute time and P the pressure (optional) .

So digital ink recognition refers to a dynamic process. The method steps on where strokes start, where they end, and in which order they were drawn to perform character, text or shape recognition.

## MyScript performs exclusively handwriting recognition with digital ink as input

So if you want to recognize the content of an image or a scanned file, we cannot help.

MyScript does not capture the ink strokes either. This is the job of the hardware that produces and collects your digital ink.
Interacting with these devices is out of MyScript SDKs scope too.
It’s up to your application to extract strokes from the devices you plan to support and send them to MyScript APIs.
For an easier integration, MyScript provides code samples on how to do so, though.

But if you’d like to have your notes strokes recognized and interpreted, you are at the right place. MyScript iink SDK is your best shot! So now let’s move forward and discover what it can do for you!

---

## Ink interpretation

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/concepts/ink-interpretation/*

Ink processing 

As soon as strokes fuel its engine, MyScript iink SDK starts the recognition.

## Recognition process

MyScript iink engine performs three processes simultaneously: symbol classification, segmentation and linguistic-based analysis.

The symbol classification and the segmentation rely on the knowledge of the existing symbols related to an input content type (an input can be a piece of text, a shape, a mathematical expression, or a drawing, etc.)

Ink strokesMyScriptrecognition engineLinguistic-basedanalysisSymbolclassificationSegmentationSymbol subset definitionLexicons,regular expressions, grammar if applicableSymbol definition,country specific profiles, if applicableRecognition output 

The segmentation tries to cut or group strokes together. Each group hypothesis attempts to match as close as possible an existing symbol. For instance, it can group strokes to form a character, or a shape and so on.

Those nested processes exchange information in a smooth way to find the most probable recognition result. Context and existing results allow to refine the recognition too.

## Recognition resources

The MyScript technologies need more than digital ink input to recognize handwriting. The linguistic-based analysis relies on a set of rules that define the way the existing symbols of an input can be combined to make up a meaningful content.

We have conceived the concept of “resources” to specify those rules. MyScript resources come as .res files. They are binary assets containing the decisive data to perform a meaningful interpretation of digital ink.

So, when you plan to perform recognition with MyScript iink SDK, it is vital to choose the resources properly. This choice highly impacts on the efficiency and the accuracy of the recognition.

According to a type of content, you select the semantic rules applied to interpret the input:
For text content, the language choice picks the alphabet and grammar. In the same way, for math content, you can choose symbols and grammar.

MyScript iink SDK comes with default resources that you might customize according to your needs.

## Recognition output

Ink preparation and interpretation carry out the recognition.
In the example below, the aim is to recognize that the word (in case of text) “hello” is written.

“hello”Recognition 

The output of the recognition process is available in the form of a tree.

The tree structure and content depend on the type of recognition that you are running: text, maths, diagram.
In any case, it contains symbol(s) or group(s) of symbols that may match the input ink.
For words, the output contains several possible matches. We refer to them as candidates.

The output tree also includes spatial information such as bounding boxes.

---

## Recognition features

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/concepts/content-types/*

Recognition features 

MyScript technology can recognize different types of content that are mainly: Text, Math and Shapes.

## Text

### Language support

MyScript technology supports up to 72 languages in cursive, handprint and superimposed writing.

As recognition is inherently related to the handwriting language, it is essential to define it properly in the first place.

It is possible to add an extra resource to support the mixed recognition of your primary language with English words.
This secondary English resource will make it easier for the engine to properly recognize English words mixed with another language.

### Recognition modes

MyScript technology supports different handwriting modes to fit user needs.

Whether you are targeting small-screen devices, tablets or interactive whiteboards and whatever your use case is, MyScript has a solution for you!

MyScript iink SDK recognizes both kinds of handwriting, whether print or cursive:

You are targeting small-screen devices, such as watches or smartphones?
You want your user to be able to write without necessarily looking at his/her device?
The superimposed mode might just be what you need!

MyScript superimposed technology enables the recognition of letters, words or parts of words written over each other, without any explicit separation between consecutive fragments.
The user can write one word fragment over the other or one character over the other, as depicted below.
Spaces between two written words are automatically added, so there is no need for an explicit gesture.

### Suggestion list

Even if MyScript technology is very reliable with handwriting recognition, a word or a character can still be incorrectly recognized sometimes.
That’s where suggestion lists come into play!

helloHellohellosheelshella 

Suggestions are alternative options for a given word or character.
Meaning in case a recognized word or character is not what users intended to write, they can choose an alternative in a list of alike words or characters.

## Math

With MyScript technology, users can smoothly handwrite mathematical operations and equations, edit them if needed, typeset them for a clean rendering and even solve them!

2 × 3 =6 

Useful export options are also available: LaTeX, MathML, image, etc.

MyScript technology obviously supports simple equations, but can also recognize complex equations and formulas.

To see the complete list of supported symbols, rules and operations, read this section.

## Shapes

MyScript technology can recognize shapes regardless of whether they are drawn in a single stroke or multiple strokes.
It is also able to identify multiple shapes in a row. To check out which shape can be identified, consult this page.

### Diagram

MyScript technology allows users to draw and annotate all kinds of diagrams.
Editing gestures are supported and a clean rendering can be obtained very easily.

In the above example, text has been centered and typeset, shapes have been aligned and made congruent.

To explore the diagram features, take a look at this section.

---

## Ink classification

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/concepts/ink-classification/*

Ink classification 

## Recognition versus classification

The process of handwriting recognition involves proposing a digital meaning from an ink signal that represent a content.

This content can be of various types, such as text, mathematics or shapes, for example.

This type of content must be considered when selecting the handwriting recognition engine to ensure that the right technology is working on the right content.

Depending on the use case, the content type is sometimes easy to identify: for a mathematics assessment, the input is assumed to be mathematical content. But in some situations, the content can be mixed, especially for notes-taking or free-writing use cases.

Therefore, a new step called classification must be introduced to identify the content types before relying on the correct recognition engine, such as:

TextClassificationMathShapeDrawing 

## Manual and automatic classifications

Classification can be done manually, where users explicitly define the type of some strokes to trigger the recognition engines accordingly.

It can also be done automatically by a dedicated process to save the effort of the manual identification.
Users can then use manual classification only to correct unexpected results from the automated process.

## Benefits

The great advantage of such classification capabilities is the freedom it gives users: they can write freely and mix different types of content.
They can select and explicitly identify some content, or even let an automatic classification process do the work of identifying content for them.

---

## Batch vs incremental

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/concepts/batch-mode/*

What are batch mode and incremental mode? 

Batch mode and incremental mode refer to the way you deliver your strokes to the recognition engine.

## Batch mode

Sometimes, you need to wait until the user has finished writing to send ink strokes to the engine and get a result.
So, you buffer the strokes before sending them to the engine: batch mode lets you send all strokes at once.

Such a mode takes only advantage of the interpretation part of MyScript technology. Export can retrieve this semantics in either common digital formats or the most-complete MyScript internal format.
Furthermore, for now, batch mode does not support any gesture.

## Incremental mode

Incremental mode means your application captures and sends ink strokes to the MyScript iink engine along the way users write.
Thus, MyScript iink SDK starts interpreting the digital ink as soon as users produce it.

ink strokes are sent as the user writes 

MyScript iink SDK analyzes the new strokes to interpret them but also to refine previous recognition results.
So this recognition process is incremental.

### Benefits

Recognition takes place as people write. As a result, full recognition results are available almost immediately after they are finished, since incremental mode focuses only on new input.
When new input is added, batch mode requires the entire content to be re-processed.
For this reason, incremental mode optimizes recognition time compared to batch mode.

When combining incremental mode with on screen usage, users can see and fix interpretation issues as they write. They can also enjoy gestures, thus experiencing full interactivity.

## Mixing batch mode and incremental mode

Incremental and batch modes can co-exist in your application with MyScript iink SDK, as they are complementary. A typical use case for mixing both modes is indexing.

Imagine you want to index for searching your notes. You will likely send strokes as a batch for all non-indexed pages but the current one, where you will send the strokes in real time. This will allow you to have current page content available for immediate search.

---

## Gestures and context

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/concepts/context-gestures/*

Gestures and context 

One of the benefits of digital handwriting is clean and direct editing.

When writing on paper, you sometimes need to modify your content: You cross off, you strike out, you add something, you write over something else… The result can be quite a mess!

MyScript iink technology lets you handwrite on a digital device just as you would on paper. But you can also take advantage of these gestures to get a cleaner result by using them to edit your content.
You can use the following gestures to improve your user experience.

There are two types of gestures: contextless gestures and content-based gestures.

## Contextless gestures

Contextless gesture algorithms can classify ink into gesture categories based on the shape of the strokes. This can be useful if you don’t fully control the content to which the gestures apply.
The downside can be a lack of understanding of what the gestures are intended to do.

## Content-based gestures

Gestures on content provide more information by indicating the content to which they apply. The content can also help to classify the gestures.

For instance, consider the following gestures:

- A contextless gesture classifier will return a single result for both cases: a left-to-right gesture.
- A content-based gesture classifier will return two different results: a strike-through gesture for the first one, and an underline gesture for the second one.

---

## Interactive ink

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/concepts/interactive-ink/*

What is interactivity 

MyScript interactive ink technology (often abbreviated as iink) is a technology from MyScript to develop UI applications holding digital content.

This technology enables a full digital experience as it can combine inputs.
Many devices already support pen or finger inputs. They capture digital ink as the result of users writing on their surfaces. The pen brings a productive advantage in many situations. But the difficulty to re-use the ink prevents it from delivering its full potential.

With MyScript iink technology, the pen is powerful for writing, while the finger manipulates content and triggers global actions.
Besides, users actually interact with the ink: they can update, correct or decorate their ink on the flow. They can also access the semantics at any time.

## Key principles

MyScript iink engine interprets the digital ink as soon as the user writes. This process is incremental as interactive ink handles new strokes without user action and refines previous result.

MyScript iink technology also provides features that come handy in digital content editors. Gestures allow either edition, action or decoration. It is thus easy to get and share right away a formatted content.

## Main benefits

- Editable:
With MyScript iink technology, handwriting becomes your very own digital font and ink edition is natural. You enjoy intelligent tools that operate on characters, words or shape primitives.
It thus makes ink a digital content that can mix with other contents like text, images, diagrams, etc.
- Productive:
The structure of MyScript iink SDK enables it to transform the ink to/from many formats. Productivity tools used in personal and professional lives can reference, annotate and/or integrate it in a document.
So, the ink content is consumable by digital applications, as there is no need for the user to export or retype it.
- Responsive:
Various form factors can display interactive ink with different device orientations. A note can be taken on a tablet, displayed on a smart phone, searched on a personal computer, etc.
Digital ink cannot easily mix with other contents as it needs resize or scrolling to accommodate different screen sizes. But MyScript iink technology reflows to adapt any geometry.

## To sum up

MyScript iink technology lets users switch between different types of contents at any time while operating on the same stream of content. It thus makes it as simple as writing on paper, but with all the benefits of editing a digital content. Its main difference with digital ink is that it transforms the input ink to an interpreted ink ready for use in your digital workflow.

MyScript iink technology is thus opening the door to future applications involving multimodal experiences. Users could choose the input that makes them the most productive in each situation. For instance, keyboard for long text, voice for on-the-go input or pen for non-linear editing, note-taking, review or graphics.

## Implementation

### Programmatic interactivity

MyScript technology offers ability to maintain an interactive context, thanks to APIs allowing you to edit the content and get the updated result dynamically.
This programmatic interactivity, also known as off-screen interactivity, is typically useful when you want to integrate an editable content into an existing application.
All these features are provided through APIs, and your application controls all the implemented behaviors.
They will allow you to:

- Add, remove, or replace ink strokes
- Receive gesture detection notifications and make corresponding ink edits
- Manage ink strokes using IDs, which can be mapped to strokes in the application’s data model
- Serialize and export to various data formats.

ApplicationiinkSDKStrokesResultexportsIncrementalprocessingData modeliink modelGestureanalyseGesturenotificationCapture 

### Rendering driven interactivity

Even if your application relies on MyScript SDK for advanced processing of user handwriting, it’s essential to handle the capture and display of ink context and facilitate user interactions.
If your application doesn’t already offer these capabilities, integrating them can lead to delays in time-to-market.
MyScript SDK can efficiently manage these aspects, offering:

- Advanced inking, supporting colors, pressure sensitivity, multiple brushes, and ink prediction for improved capture speed.
- Content rendering, with zoom, scroll features, text reflow, and user assistance such as alignment guides and connector snapping.
- Content management, including Undo/Redo functionality, precise content selection, with the ability to cut/copy/paste, and ink-to-text conversion.
- Gesture detection for both stylization and content editing.

ApplicationiinkSDKResultexportsIncrementalprocessingCaptureUI Reference implementationiink model

---

## Rendering-driven interactivity

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/concepts/ink-capture/*

Ink capture 

The principle of rendering-driven interactivity is to delegate the display management to MyScript iink SDK so that it can handle the entire rendering canvas and perform all interactivity functions for you.

It allows you to benefit from advanced interactive features at low cost. The first benefit is drawing the iink context. MyScript iink SDK will display all elements (strokes, text glyphs, shapes, images).

It will also manage the ink capture and its rendering, offering you multiple options to meet your user expectations by allowing you to configure:

- The color.
- The stroke size, based on pressure, writing speed, or a mix of both.
- The brush style.

The latency of ink capture is optimized to provide the best writing experience for the user.
However, hardware and system limitations can affect this latency.
Therefore, MyScript SDK provides advanced ink prediction technology that allows you to overcome device limitations.

---

## Gestures

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/concepts/editing-gestures/*

Gestures 

In the on-screen interactivity mode, the MyScript iink technology is designed to reflect the results of the research conducted by the MyScript UX team.

## How we chose our set of iink gestures

When MyScript started defining interactive ink, we were offering a wider range of gestures than today.
Our UX research has then shown that the amount of gestures made our applications hard to learn and use.
The rule that the human working memory can only hold three items at a time proved to be true. So, we have set out to find a way to simplify gestures to shorten our products learning curve.

We also took into account the recognition rate: The gestures should be easy to disambiguate from handwriting and should lead to the highest possible recognition rates for both gestures and handwriting.

So after the introduction of our set of interactive ink gestures, we saw that when they were used as taught, the recognition rate we targeted was reached. Overall it has led to a much higher adoption of gestures compared to before interactive ink. And the story to tell the world had become a lot simpler!

Based on this research work and our accumulated experience, we have decided to go for the following ink gestures.

## Ink gestures

- To erase a letter, a symbol, a word, a formula or a paragraph, scratch it out or strike it through:

- To insert a word in your sentence, draw a straight line downwards (or several) to create an extra space.

- To bring two words closer, you can either draw a straight line upwards:

or draw a line from one word to the next one:

- To add a freeform section into a "Text Document" part, draw a line from left to right across the page, we call this gesture the slice gesture:

## Decoration gestures

- To highlight your text, draw a frame to surround it:

- To define a subtitle or a title, just underline or double underline it:

## Touch gestures

Besides the gestures described above, MyScript iink technology supports extra touch gestures.
These gestures allow users selecting one or several items either handwritten or typeset:

Actions associated to touch gestures allow applying a change on items.

- Actions can be replacing handwritten ink by typeset:

hello 
- Beautifying a diagram:

- Showing or hiding a contextual menu:

Copy 
- Moving and/or resizing selected block:

Hello worldHello world 
- Moving a selected item:

## To sum up gestures

With MyScript iink technology, use your pen to write, and your finger to interact! But if you want to modify this default behavior, you can reroute your input events so that they correspond to another MyScript iink event type.

---

## Smart tools

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/concepts/smart-tools/*

Smart tools 

In rendering-driven use cases, besides gestures, MyScript iink technology proposes a string of smart tools all ready to put to work.

Their intelligence relies on their capacity to adjust to the ink structure and semantics. Interactions with typeset and ink content are accordant.

## Eraser

The eraser tool detects the touched item and deletes it. Item can be either a stroke, a shape, a connector, a character, or a word according to your content.

The eraser processes handwriting and typeset items in the same way.

You can tune behavior to either erase strokes or ink parts within trajectory.

## Typeset

According to your working mode, MyScript iink engine adjusts the typeset of the ink.

It handles up to two different modes, ‘publish’ and ‘edit’, according to your content type:

- ‘publish’ means that your typeset content is ready for publication. MyScript iink engine then uses small font size and fitted graphics.
- ‘edit’ stands for typeset content suitable for edition. Font size is large enough for smooth editing work. Graphics are expanded for handy update.

Interactivity allows you switching from one mode to the other one. This means that you can edit your typeset content and insert some handwritten ink into it. You may also scratch typeset content to erase it.
Copying and pasting both handwritten and typeset items from one another is also possible.

To sum up with interactive ink, processing typeset or handwritten content is transparent.

## Lasso selector

The selector tool lets you draw a lasso to select some content:

Lasso selection 

Then, MyScript iink engine analyses this selection to let you interact with it. Depending on the context and the content, you can move or scale the selected items, apply some formatting, copy or typeset them, etc.

## Highlighter

The highlighter tool allows you to emphasis content by adding transparent color anywhere in a page, regardless of the type of content.
In addition, with a long press, it can be used as a coloring tool of shapes or to change ink, lines, arcs or text colors.

Highlighter tool

---

## Responsive and productive

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/concepts/responsive-layout/*

Responsive and productive 

In rendering-driven use cases, besides gestures and smart tools, MyScript iink technology proposes you responsive and productive tools.

## Reflow

MyScript iink technology enables interactive content, either handwritten or typeset, to reflow and tune to the view size.

Changing your device orientation or switching device triggers this reflow. MyScript iink engine might modify block dimensions or update ink size and arrangement when necessary.

## Digital content ready to use in your digital workflow

In addition, you can create a full ready-to-use digital document from your ink, empowering your productivity.
Interactive ink lets you structure your content in several areas. Each one has a specific and dedicated purpose: Text, Math, Diagram or Raw content.

So, MyScript iink technology offers you a container hosting a collection of items as a dynamic and responsive stream of contents.

Furthermore, you can manipulate each of them using touch gestures. You can move and resize blocks, making the formatting an easy task.

Once you have finished your editing, you can export your content in a format compatible with your digital workflow such as docx or html.
MyScript iink technology thus makes your ink immediately available for reuse into your digital workflow.

---

## Handwriting generation

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/concepts/handwriting-generation/*

Handwriting generation 

Handwriting generation is the process of converting digital text to digital ink by creating the basic strokes that form the letters, words, and sentences of the input text.

HandwritingGeneratorHello[ { “x”: [ 4.77, 4.74, 4.70, 4.72, 4.76, 4.78, 4.84, 4.81, 4.84, 4.81, 4.79, 4.77, 4.70, 4.69, 4.64, 4.78, 4.90, 5.17, 5.51, 5.91, 6.48, 7.08, 7.43, 7.62, 7.71, 7.77, 7.83, 7.81, 7.85, 8.19 ], “y”: [ 13.27, 13.84, 14.42, 14.91, 15.49, 16.03, 16.52, 17.15, 17.73, 18.27, 18.79, 19.36, 18.86, 18.34, 17.84, 17.23, 16.75, 16.25, 15.69, 15.40, 15.25, 15.41, 15.77, 16.28, 16.76, 17.36, 17.93, 18.55, 19.04, 18.71 ], “t”: [ … , … ], 

It involves various settings that affect the quality, style, and flow of the handwriting.

## Predefined handwriting profiles

When generating ink, the handwriting generator can use a predefined handwriting profile from among those available in its dataset.
Depending on the selected profile, it will calculate the corresponding strokes and the generated ink will look different:

HelloPredefinedhandwriting profilesHandwritingGenerator 

## Estimate handwriting profiles

The handwriting generator can also learn user profiles from handwriting samples.
It will then be able to generate strokes from the input text that will be like the user’s handwriting style.

Amino acids are theessential building blocksof proteins, which carryout almost every function inour bodies. Writing style estimatorUser handwritingprofileHandwritingGenerator 

## Beautify user handwriting

Beautification refers to the process of improving and refining handwritten ink to make it aesthetically pleasing and elegant.
In this context, embellishment may involve improving the shape of the letters, symbols or shapes, or adjusting the spacing and flow to create a polished result.

---

## About

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/overview/about/*

About MyScript iink SDK 

MyScript iink SDK is a development toolkit provided by MyScript to help integrators build
interactive-ink-enabled applications.

Its goal is to provide the right balance between flexibility and ease of integration, in order to maximize the value brought to end users for an optimized time to market.

MyScript iink SDK is built to be:

- Relevant for a wide range of use cases,
- Cross-platform,
- Easy to use and to interoperate with other solutions,
- Flexible to accommodate different integration scenarios,
- Compliant with Interactive Ink principles.

## Use cases

There are many use cases where pen input can add value to a user’s workflow.
Among the use cases that the current version of MyScript iink SDK can push to the next level, we can highlight the following non-exhaustive list:

- Note-taking, with the ability to use Text Document content types to support simple or advanced note-taking,
depending on whether you intend to input short notes or complex notes with advanced layout capabilities.
- Form-filling, with fields of different types that can be filled directly on canvas or in a dedicated input and exported for validation
and automated processing.
- Diagram input, for instance in the case of office suites, to let your users quickly add diagrams to their documents without fighting
their way through several trays of shapes or options.
- Math or text-based exercises, with the ability to write those types of content and extract student inputs for automatic hints or assessment.
- Creative sessions, to let you write and draw freely on a wide canvas with a Raw Content and use
a lasso or hand selector to select some areas or blocks within the canvas for converting them,
copying them to paste them in the same app, or exporting them for reuse in other apps.
- Input method, to offer the possibility to write content into text field, and detect edition gesture on top of it​.
- Live content, to let you interact with any content by identifying gesture on top of any item​.

## Cross-platform

To let you reach your users where they are, whatever their device is or the platform you are building, we designed iink SDK to be portable from the ground up,
with limited platform-specific parts.

MyScript iink SDK already supports several platforms, including mobile, desktop and the web.

Our goal is to have all supported platforms providing the same set of functionalities each time it makes sense.
While some platforms such as the web do not support the full breadth of what is possible with MyScript iink SDK yet – because of the specific challenges they pose,
we are working hard to improve in that respect.

## Ease of use and interoperability

With MyScript iink SDK, MyScript does the heavy lifting for you, bringing its twenty years of experience around handwriting recognition into simple APIs
and a sensible default configuration.

Should you need to do so, a wide choice of [configuration](../../reference/configuration/)or [styling](../../reference/styling/)options still lets you tune the
default behaviors without the hassle of implementing anything by yourself. 

We also aim at staying close to what you know, with platform-specific bindingsand the support of popular package managers like
CocoaPods or NuGet, making it a breeze to integrate MyScript technology.

Finally, we favor semantic manipulation of model content, with the support of a readable and parseable exchange format that makes it
possible to exchange information with the host application or any third-party solution.

## Integration flexibility

In addition to its cross-platform nature, iink SDK is meant to enable a significant flexibility in terms of
integration scenarios:

- Code examples and a ready-to-use implementation of platform-specific parts (including some UI parts) make it easy to
quickly address light integration needs.
- Platform-specific bindings give you access to a more flexible API that lets you implement your use cases, tune the provided platform implementation or
even develop a totally new one to support any particular graphical toolkit you are required to use.

---

## What's new

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/overview/changelog/*

What's new 

## Introducing the iink SDK 4.️2 native APIs

The C# bindings for Windows are not available for new APIs. If you need them, [contact our sales team](../../../../../../contact). 

## Handwriting generation for Chinese

Since the release of iink SDK 4.1, handwriting generation has been possible for English text. With iink SDK 4.2, handwriting generation is also possible for Chinese text (GB2312 character set).

### New and updated handwriting generation APIs

- The handwriting-generation.init.resource configuration property allows you to set the corresponding resource for the desired language.
- The HandwritingProfileBuilder class now has a new method, getPredefinedProfileCount, which retrieves the number of predefined writing profiles embedded in the language resource.
- The getPredefinedProfileAt method allows you to retrieve the desired profile by index.
- The getPredefinedProfileCount requires the resource to be loaded, otherwise, it will load it synchronously. To avoid the extra cost of loading when getting the number of predefined profiles, you can preload the resource using HandwritingGenerator loadResource.

### Improved control of stroke location for handwriting generation.

We have also introduced the handwriting-generation.session.origin-x-mm property to improve control of stroke location for handwriting generation.
This property can be useful for implementing progressive handwriting generation or completing an existing paragraph.

➤ To learn how to use the handwriting generation objects and resources, see the Handwriting generation user guide.

## New features in variable management

### Easier variable definition with MathSolverController

- You can now set or retrieve the values of global variables that apply to all blocks by setting an empty string as the block ID.
- The getVariableDefinitions method lists all variable definitions, including their source type and associated block.
When auto-variable-management is enabled, this list includes block variable definitions that are automatically identified.

### Variable definition updates

- Variables can now use a Latin or Greek letter as a subscript (e.g. “A_n”). This allows your users to define some standard constants more easily.
- Variable definitions can now contain multiple equal signs, such as: “a = 1/2 = 0.5” .
In the case of an inequality, the variable is defined using the first value. For example, “a = 5 = 6” defines “a = 5”.

➤ For more details on how to manage math variables and the latest math solver APIs, see the Math interactive features page.

## Vertical operations support

Our advanced analyzer raw-content2 combined with the math2 bundle now supports vertical operations (multiplication, division, addition, and subtraction) using a single [+-*×/:÷] operator per line and decimal numbers.
With the appropriate configuration, the Raw Content Editor, OffscreenEditor, and Raw Content Recognizer can thus recognize vertical operations and the MathSolverController can solve them.

## Other changes

### The MathSolverController can now generate strokes for OffscreenEditor.

To help your Math integration with the OffscreenEditor, the MathSolverController can now generate the strokes and the bounding-box of the solver result in the JIIX action output.
The default Math configuration associated with the OffscreenEditor has been modified to activate this feature by default.

### New LaTeX label for Math blocks in JIIX

To facilitate math integration, JIIX Math blocks now come with LaTeX labels containing the associated recognition result.

### Support for degree signs in math expressions

The MathSolverController can now solve expressions such as cos(60°) and provide the correct result, 0.5 in this case, by considering the annotated value in degrees regardless of the math.solver.angle-unit configuration (rad or deg).

### Easier block management in Raw Content parts with contentChanged2 notifications

The IEditorListener and IOffscreenEditorListener interfaces now include a new method, contentChanged2.
This notification provides lists of added, removed, and updated blocks whenever the content of a Raw Content part changes.
These lists make it easier to maintain associations between blocks in the Editor/OffscreenEditor and objects in your application.

### Vertical Japanese support

We now support vertical Japanese writing in non-interactive mode.

### New APIs to retrieve oriented bounding boxes for blocks

The new getOrientedBox API in ContentBlock and getBlockOrientedBox API in ItemIdHelper return the four points of the oriented bounding box for blocks.

### Update to the latest MyScript technology

MyScript iink SDK 4.2 is based on the latest version of MyScript technology, which improves classification and recognition performance and brings general improvements.

While recognition assets provided with MyScript iink SDK 4.1 will stay compatible, you may want to update your users to the latest assets if you migrate them to 4.2.

If you upgrade from 4.1, please take a look at the [migration guide](../migration-guide/).

---

## Migration guide

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/overview/migration-guide/*

Migration guide 

This page lists the key points to pay attention to when migrating existing code from to the latest MyScript iink SDK APIs.

## Migrating to iink SDK 4.️2 native APIs

## Handwriting generation changes

With the introduction of Chinese text handwriting generation, we have renamed the resource file for English text from hw-gen.res in 4.1 to en-hw-gen.res in 4.2.
So, be sure to deploy the new en-hw-gen.res resource in your handwriting generation project when upgrading to 4.2.

### Refactoring of createFromId

The HandwritingProfileBuilder class now has a new method, getPredefinedProfileCount, which retrieves the number of predefined writing profiles embedded in the language resource.
For consistency, the createFromId method has been renamed getPredefinedProfileAt which allows you to retrieve the desired profile by index.

This change results in the removal of the PredefinedHandwritingProfileId enum, which is now useless.

For more details, see the Handwriting generation user guide.

### Control of stroke location for handwriting generation.

If you were using the handwriting-generation.session.left-x-mm property with iink SDK 4.1, note that you can now better control stroke location:

- Set the handwriting-generation.session.origin-x-mm property to the generation position of the first line, if you want the first line to be in a different position than the other lines.
- Use the handwriting-generation.session.left-x-mm property for the left alignment/clipping boundary of the other lines.

### OffscreenEditor default Math configuration changes

The default Math configuration associated with OffscreenEditor has been modified to ensure that strokes generated by the MathSolverController and their bounding box are provided without any additional configuration when requesting the JIIX action output:

- math.solver.enable-syntactic-correction is now false.
- math.solver.display-implicit-multiply is now false.
- math.solver.numerical-computation is now [ "at-right-of-equal-sign" ].

To avoid the new default configuration, and keep the previous one, modify the OffscreenEditor configuration immediately after creation as follows:

```java
// retrieve OffscreenEditor current configuration
Configuration conf = offscreenEditor.getConfiguration();
// set previous default values
configuration.setStringArray("math.solver.numerical-computation", arrayOf("anywhere"))
configuration.setBoolean("math.solver.enable-syntactic-correction", true)
configuration.setBoolean("math.solver.display-implicit-multiply", true)
```

### New LaTeX label for Math blocks in JIIX

To facilitate math integration, JIIX Math blocks now come with LaTeX labels containing the associated recognition result.
If you don’t want this label, you must set the export.jiix.math-label setting to false, as it is enabled by default.

### New vertical operation rule

Our advanced analyzer raw-content2 combined with the math2 bundle now contains a new VopRule allowing it to recognize vertical operations.
You can build and use an SK resource that bans the VopRule rule to prevent vertical operations from being recognized.

### New contentChanged2 method for IEditorListener and IOffscreenEditorListener

The IEditorListener and IOffscreenEditorListener interfaces now include a new method, contentChanged2.
This notification provides lists of added, removed, and updated blocks whenever the content of a Raw Content part changes.

### Support of export.jiix.text.lines by the Raw Content Recognizer

The configuration export.jiix.text.lines is now supported by the Raw Content Recognizer.
Since its default value is false, JIIX export of Raw Content Recognizer text blocks no longer includes the “lines” object.

➤ To keep the previous behavior, you must set export.jiix.text.lines to true.

### MyScriptPrediction library removal

The MyScriptPrediction library is no longer shipped since 4.0.0 because it is no longer used.
However, as of 4.1.0, this library is no longer compatible with other libraries, so if is still in your environment, you may encounter errors when loading the iink libraries and your application may crash at runtime.

To avoid problems when upgrading to 4.2, search for any file named *MyScriptPrediction.* in your application environment and delete it.

---

## Integration

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/overview/platforms/*

Supported platforms 

## Platform and APIs

The following table lists the platforms and architectures that are qualified for the MyScript iink SDK 4.2 release:

| Platform | Min version | Max version1 | Architectures | APIs |
| --- | --- | --- | --- | --- |
| Android2 | 5.0 | 16.0 | armeabi-v7a3, arm64-v8a4, x86, x86_644 | Java Android |
| iOS | 15.0 | 18.7.1 | x644, arm644, M14 | Objective-C (Swift-compatible) |
| Windows UWP5 | Win 11 build 261006 | Win 11 build 26100 | x64, arm64 | WinRT |
| Windows Desktop | Win 10 build 19041 | Win 11 build 26100 | x644 | .NET7 |
| Web | | | | JavaScript, WebSocket, REST |

If your requirements extend to other platforms, please [contact our sales team](../../../../../contact). 

## Should I go native or web?

The answer depends on your requirements.

You should probably use the native version if:

- You cannot allow or ensure your users the access to an Internet connection.
- You need to provide end users with content types that are not yet supported in the web, such as diagram or text document.
- You want to have a fine control over the types of devices you consider or want to make use of specific hardware features linked to the stylus.
- You want to avoid sending data to a remote server.

You should probably use the web version if:

- You are developing a web or an hybrid application.
- You prefer off-loading the recognition overhead to a remote server to spare resources on the local device.
- You have data confidentiality constraints but you are ready to host the MyScript iink SDK server.

If you are interested in the on-premise version of the MyScript iink SDK server, please [contact our sales team](../../../../../contact)for more
information and pricing. 
1. Last qualified version for the current release. Theoretically, newer versions of the platforms should be compatible. ↩
2. Can be embedded into Android applications running on Chrome OS as well. ↩
3. Requires Neon support. ↩
4. Supports Math and Raw Content Recognizers, and latest math and Raw Content analyzer bundles for Editor and OffScreenEditor. ↩ ↩2 ↩3 ↩4 ↩5 ↩6
5. Support for UWP / WinUI 2 in iink SDK is deprecated and may be removed in a future release. ↩
6. Windows versions ↩
7. Comes with a WPF UI reference implementation and examples. ↩

---

## Integration levels

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/overview/integration-levels/*

Integration levels 

In some cases, integrating MyScript iink SDK can be as simple as configuring and adding a view to your application.
However, it may sometimes call for a deeper integration. MyScript iink SDK offers this flexibility via the support of different integration levels.

Depending on the circumstances, MyScript iink SDK can be integrated at different levels:

1. Code examples
2. Platform-specific bindings
3. Cross-platform or server APIs

## Code examples

MyScript provides integrators with code examples to ease the integration of MyScript iink SDK.

This code is released under the permissive [Apache 2 license](https://www.apache.org/licenses/LICENSE-2.0).
This lets you free to modify and integrate it into your own solutions without restrictive constraints. 

### Native platforms

The example code repositories (one per platform) provide useful examples illustrating some usages of the SDK that you can import into
your own project. More importantly, it comes with a reference UI implementation for the target platform that consists in a set of classes that you can
directly reuse to get a working base to build on.

All the code relies on platform-specific bindings, making it both easy to integrate into your project and to tune to your liking.

### Web

Ready-to-use examples based on our iinkTS library expose samples that you can integrate in your project.

## Platform bindings

### Native platforms

MyScript iink SDK comes with platform-specific bindings for Android, iOS and Windows, which let you integrate the toolkit using the main programming
language(s) of the target platform.

Bindings provide a flexible entry point and offer functionalities you may require. For example, you may need to tune the provided UI reference implementation or
even develop a new one. The latter could be useful if you have specific requirements, such as a particular graphical toolkit or performance optimization
specific to your use case.

### Web

MyScript iink SDK is supported by the iinkTS library that you can directly use or tune for more flexibility.

Just like the code examples and the UI reference implementation, iinkTS is released under the permissive [Apache 2 license](https://www.apache.org/licenses/LICENSE-2.0). This lets you free to modify and integrate it into your own solutions without restrictive constraints. 

## Cross-platform/server APIs

### Native platforms

MyScript iink SDK comes with a cross-platform C++ API (only available on demand) that supports a wide range of
platforms.

As a generic, non-graphical API, it is flexible when it comes to cross-platform development, but you may need more efforts in some cases to
develop the different UI parts.

### Web

The Web platforms provides low-level WebSocket and REST APIs that can be used to integrate Interactive Ink
into native or web applications alike.

MyScript does not necessarily recommend the WebSocket API to all integrators, as it requires significant work, e.g. to parse the
SVG deltas to apply for the rendering.

---

## Recognition capabilities

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/overview/recognizers/*

Recognizers 

The recognizers aim at performing real-time incremental recognition on transient ink.

## Use cases

They are intended to address use cases like input-method writing solutions based on iink SDK, where your application performs the strokes capture and rendering.
They simplify iink SDK integration when the ink is simply an input medium for digital content.

Application iink SDK Strokes Result exports Incremental processing Capture 
- The Gesture recognizer is dedicated to the recognition of gestures without any text context. It is agnostic to the current language settings.
- The Text recognizer enables the recognition of text in incremental mode.
- The Math recognizer enables the recognition of math.
- The Shape recognizer enables the recognition of shapes in incremental mode. It is dedicated to the recognition of shapes only: no matter which ink content is sent to the Shape recognizer, it returns the shape(s) that it recognizes, with alternative recognized shape(s), if any.
- The Raw Content recognizer is designed to analyze and recognize digital ink into text, math, shape, decoration or other elements whose semantics are known to iink SDK. The input digital ink does not require any explicit segmentation.
Depending on its classification configuration, the recognizer analyzes the content to extract the document layout as blocks and classify ink strokes according to their types.
Once ink is classified, recognition is performed according to recognition configuration.

In incremental mode, Recognizers process the first strokes in the background while the user keeps writing more strokes. That background recognition process starts as soon as the first stroke is written.

## Available result formats

- Text Recognizer: JIIX, raw text.
- Gesture Recognizer: JIIX.
- Shape Recognizer: JIIX.
- Math Recognizer: LaTeX.
- Raw Content Recognizer: JIIX.

## Integration tips

Visit this page to learn how to use the recognizers with our native SDK, and this this page for the Web APIs.

---

## Text languages and features

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/overview/text-languages/*

Text languages and features 

MyScript iink SDK can recognize an extended range of languages and text features.

## Languages

This is the list of the different languages that are can be recognized by the MyScript engine.

- Arabic
- Afrikaans - South Africa
- Albanian - Albania
- Armenian - Armenia
- Azeri - Azerbaijan1
- Basque - Spain
- Belarusian - Belarus
- Bosnian - Bosnia
- Bulgarian - Bulgaria
- Catalan - Spain
- Cebuano - Philippines
- Chinese Simplified - China
- Chinese Traditional - Hong Kong
- Chinese Traditional - Taiwan
- Croatian - Croatia
- Czech - Czech Republic
- Danish - Denmark
- Dutch - Belgium2
- Dutch - Netherland
- English - Canada
- English - Philippines
- English - South Africa
- English - United Kingdom
- English - United States
- Estonian - Estonia
- Farsi - Iran
- Filipino - Philippines
- Finnish - Finland
- French - Canada
- French - France
- Irish - Ireland3
- Galician - Spain
- Georgian - Georgia
- German - Austria
- German - Germany
- Greek - Greece
- Hebrew - Israel
- Hindi - India
- Hungarian - Hungary
- Icelandic - Iceland
- Indonesian - Indonesia
- Italian - Italy
- Japanese - Japan4
- Kazakh - Kazakhstan
- Korean - Korea
- Latvian - Latvia
- Lithuanian - Lithuania
- Macedonian - Macedonia
- Malagasy - Madagascar
- Malay - Malaysia
- Mongolian - Mongolia
- Norwegian - Norway
- Polish - Poland
- Portuguese - Brazil
- Portuguese - Portugal
- Romanian - Romania
- Russian - Russia
- Serbian (Cyrillic) - Serbia
- Serbian (Latin) - Serbia
- Slovak - Slovakia
- Slovenian - Slovenia
- Spanish - Colombia
- Spanish - Mexico
- Spanish - Spain
- Swahili - Tanzania
- Swedish - Sweden
- Tatar - Russia
- Thai - Thailand
- Turkish - Turkey
- Ukrainian - Ukraine
- Urdu - Pakistan
- Vietnamese - Vietnam

### Superimposed

All languages from the previous list can be recognized both in cursive and superimposed modes.

### Non-interactive languages

While most of the languages in the previous list are compatible with both interactive and non-interactive modes, the following additional languages are restricted to non interactive mode:

- Arabic
- Farsi - Iran
- Hebrew - Israel
- Hindi - India
- Thai - Thailand
- Urdu - Pakistan
- Vertical Japanese - Japan

## Emojis

- 7 base emojis can be recognized as part of the text, along with a total of 16 variants coming as text candidates:

❤ (variants: 💓, 💙, 💕)
💔 (variant: 💘)
😐 (variants: 😒, 😓)
🙂 (variants: 😁, 😃, 😍, 😄, 😊)
🙁 (variants: 😞, 😭, 😠, 😩)
😉 (variant: 😜)
🙃

So drawing following emoji will let you choose among the variants by selecting your favorite candidate:

😀😁😍😄😊 
- Warning sign: ⚠️
- Cloud sign: ☁

## Other notable recognition features

- Circled digits: ① ② ③ ④ ⑤ ⑥ ⑦ ⑧ ⑨ ⑩ ⑪ ⑫ ⑬ ⑭ ⑮ ⑯ ⑰ ⑱ ⑲ ⑳ and Circled asterix: ⊛
- Checkable items:
The following ballot boxes can be recognized: ☐ ☑ ☒.

Futhermore, either on ink or already converted the ballot box ☐ can be checked with the 🗸-type mark or the x mark.
The conversion will then produce the ☑ and ☒ ballot boxes.

When a ballot box starts a line, tapping on it will check it with the 🗸-type mark too.

- Ballot x: ✗ is supported as a bullet.
- Mathematics: ∀, ∃, ∄, ∈, ∉, ⟂
- Greek: α, β, Δ, Σ
- Units: ½, ⅓, ¼, ⅔, ¾, m², m³

1. Also called Azerbaijani. ↩
2. Also called Flemish. ↩
3. Also called Gaelic. ↩
4. Vertical Japanese writing is supported in non-interactive mode only. ↩

---

## Math elements and rules

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/overview/math-elements-and-rules/*

Math elements and rules 

MyScript iink SDK can recognize the following math elements and rules.

## Elements

| Type | Items |
| --- | --- |
| Letters (Latin alphabet) | a b c d e f g h i j k l m n o p q r s t u v w x y zA B C D E F G H I J K L M N O P Q R S T U V W X Y Z |
| Digits | 0 1 2 3 4 5 6 7 8 9 |
| Mathematical symbols (including operators) | € $ £ ¥ ₩ ¢ ( ) [ ] { } ! # % ‰ & ? @ / \ \| ∥ ∦ © ∂ ∅ ∇ ∞ + - ± × ÷ * √ ¬ ∘ · ‘ , . : ; _ ← ↑ → ↓ ↔ ↕︎ ↖︎ ↗︎ ↘︎ ↙︎ ↼ ⇀ ↽ ⇁ ⇋ ⇌ ⇐ ⇑ ⇒ ⇓ ⇔ ⇕ ∀ ∃ ∄ ∈ ∉ ∋ ∌ ∪ ∩ ⊂ ⊃ ⊄ ⊅ ⊆ ⊈ ⊇ ⊉ ∝ ∏ ∐︎ ∑ ∫ ∬ ∭ ∮ ∯ ∰ ℂ ℕ ℚ ℝ ℤ 𝔻 ℑ︎ ℜ︎ = ≠ ≒ ≡ ≢ ∼ ≃ ≄ ≅ ≆ ≇ ≈ ≉ < > ∧ ∨ ≤ ≥ ≮︎ ≯︎ ≰︎ ≱︎ ≪ ≫ ⋉ ⋊ ⋮ … ⋱ ⋰ ⌈ ⌉ ⌊ ⌋ □ △ ⟦ ⟧ ⟨ ⟩ ∠ ⦞ ℏ ⊥ ⫻ ⊕ ⊗ ⊖ ⊙ ∓ ∵ ∴ ≦ ≧ ℱ ℒ ⌒ |
| Greek symbols frequently used in mathematics | Γ Δ Θ Λ Ξ Π Σ Υ Φ Ψ Ωα β γ δ ε ζ η θ ι κ λ µ ν ξ π ρ σ τ υ φ ϕ χ ψ ω |
| Mathematical terms | dx dy dz dt sin cos tan cot asin acos atan acot arcsin arccos arctan arccot cosh sinh tanh coth acosh asinh atanh acoth arcosh arsinh artanh arcoth min max arg argmin argmax inf sup lim liminf limsup ln log exp lg card Im Re det dim deg sec Pr csc ker gcd mod |
| International convention units (weight, length, frequency, luminosity, dosage, pressure, etc.) | km hm dam dm cm mm µm ha hl dal dl cl ml µl kg hg dag dg cg mg µg ms µs GHz MHz kHz Hz µA µC µF µHz µJ µN µPa µS µT µV µW µWb µWh µbar µcd µeV µlm µlx |

### Rules

| Rule | Structure | Written example | LaTeX result |
| --- | --- | --- | --- |
| Horizontal pair | | | |
| Fence | { } [ ] ( ) | | |
| Fence | | | |
| Square root | | | |
| Fraction | | | |
| Subscript | | | |
| Superscript | | | |
| Subsuperscript | | | |
| Presuperscript | | | |
| Overscript | | | |
| Underscript | | | |
| Underoverscript | | | |
| Vertical pair | | | |
| Vertical list | … | | |
| Matrix | …… | | |
| Partial fraction (numerator) | | | |
| Partial fraction (denominator) | | | |
| Slanted fraction | | | |
| Vertical operation1 | | | |

1. Vertical operations with a single operator per line [+-*×/:÷] and decimal numbers can be recognized by Raw Content Editor and OffscreenEditor configured with advanced analyzer, as well as Raw Content Recognizer. ↩

---

## Shapes and connectors

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/overview/diagram-features/*

Shapes and connectors 

## Shapes

Here is a list of the supported shapes:

Polyline arrowPolyline doublearrowPolylineLineArrowDoublearrowCurvedarrowDoublecurvedarrowArc of circleArc of ellipseCirclesEllipsesRectanglesParallelograms TrapezoidsPolygonsRhombusesQuadrilateralsSquares EquilateraltrianglesTrianglesIsoscelestrianglesRighttrianglesRight isoscelestriangles 

## Link items

To create diagram, you also need to link shapes and text.
Once two items are linked, moving/resizing one means moving/resizing the other accordingly.

- Write text inside a shape to link both:

- Write text next to a shape connector to link both:

- Draw a shape connector between two shapes to link them:

- Draw two shape connectors close to each other to link them:

- Label a shape connector to link both:

As shown in the below figure:

- When text is written inside a shape, the connector is linked to the shape, and not to the text.
- When there is no shape, the connector is linked to the text.

When two elements are linked by a connector, it is called a “node”.
A node can either be a shape, some text or even free drawing.

When the user places a unique and centered piece of text inside a shape, it is called a “cell label”.
If text is placed near a connector, it is called a “label”.

---

## Gestures

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/overview/gestures/*

Gestures 

MyScript iink SDK can identify writing and touch gestures, allowing to integrate any kind of interactive features.

## Ink gestures

| Name | Gesture |
| --- | --- |
| left-right | |
| top-bottom | |
| right-left | |
| bottom-top | |
| scratch | |
| surround | |

## Touch gestures

| Name | Gesture |
| --- | --- |
| tap | |
| double-tap | |
| long-press | |

---

## Interactivity integration

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/overview/content-types/*

Content types 

MyScript iink SDK lets you consistently interact with different types of content via a unified API.
This page lists supported content types and outlines the potential specificities of each of them.

## Supported content types

MyScript iink SDK currently supports the following content types:

- Text ("Text") - Simple block of multi-line text (including possible line breaks), responsive reflow. It shows guides by default but these can be
deactivated (for instance when processing ink from an outside source that is not aligned on the guides).
- Math ("Math") - Block supporting one or more equation.
- Diagram ("Diagram") - Block supporting a diagram, with automatic text/non-text distinction and dynamic reorganization possibilities.
- Text Document ("Text Document") - Container hosting an ordered collection of text, math, diagram, raw content and drawing blocks.
It is a vertical, dynamic and responsive stream of structured content.
- Raw Content ("Raw Content") - Block hosting digital ink with no explicit segmentation into text, math, shape or other items which semantics is known by iink SDK.
In addition it can contain images and placeholder blocks.

**Raw Content**type is the only content type available for programmatic interactivity supported by **Offscreen Editor**. 

## Raw content highlights

### Raw content analyzer

Raw content ink is analyzed by MyScript iink SDK to determine the document layout and classify the ink according to the identified content types:
Depending on the classification configuration and on its analyzer bundle, MyScript iink SDK can distinguish text, math or shape blocks from drawing blocks.
Inside a text block, it can even identify math elements.

If classification types is empty, the analysis process is reduced, allowing to use Raw Content for optimized drawing.

You can choose between two different analyzers when using an Editor or an OffscreenEditor:

- The legacy analyzer bundled raw-content, that runs on all platforms.
- The advanced analyzer bundled raw-content2, that improves the document layout analysis and ink classification. This new analyzer also makes it possible to perform math automatic classification.
Combined with the math2 recognition bundle, it allows you to perform math recognition in Editor and OffscreenEditor Raw Content.

Currently, the advanced analyzer bundled `raw-content2`may not be available on your platform. [Check](../platforms/)if it is available for your platform. 

### Raw content flexibility

Then, according to the recognition configuration, recognition is performed with the correct engine per content type.

Raw Content is therefore very flexible and allows specific behaviors depending on its configuration, making it the key to implementing various use cases:

- Word search functionality on raw digital ink. You can obtain this information via a JIIX export.
- Interactive raw content, where you write and draw freely on a wide canvas and interact with the content thanks to MyScript iink SDK interactive features:
you can select some content to apply actions as copying or exporting it for further use, converting it, or transforming it.
Note that by default, these features are not activated for the “Raw Content” type, so you should tune your configuration to benefit from them.
- Keyboard input with a placeholder block, where you can add an image of a text widget, and when users want to edit text, the widget appears where the image is. Users can then type directly into the widget using the keyboard. Once editing is finished, the text is converted into an image and added back to the iink context. The text widget is controlled by the integrator, not by MyScript iink SDK.
- Doodling and drawing activities, allowing you to benefit from interactive tools (lasso, copy/paste,…).

For an overview of what is possible with Raw Content, refer to the interactive features page.
In addition the configuration reference page lists what you may tune and the configuration section how to easily do it.

**Raw Content**type is the only content type available for programmatic interactivity supported by **Offscreen Editor**. 

## Integration tips

The string value provided between brackets is case-sensitive and identifies the type in the model in an unambiguous way.

For a wider presentation of all types of content that MyScript technology can recognize, along with possible use cases, refer to the
detailed presentation in the Concepts section of this documentation.

- Supported text recognition languages
- Supported math features
- Supported diagram shapes
- Supported interactive features per content type
- Supported import/exports per content type

---

## Interactive features

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/overview/interactive-features/*

Interactive features 

MyScript iink SDK supports various interactive features.

Supported gestures and smart tools depend on the type of content. The possibilities are summarized by the following tables.

## Programmatic interactivity with OffscreenEditor

### Ink gestures

| | Raw Content1 |
| --- | --- |
| Scratch | X |
| Strikethrough | X |
| Join | X |
| Insert | X |
| Surround | X |
| Underline | X |

## Rendering-driven interactivity with Editor

### Editing and decoration gestures

| | Text Document | Text | Diagram | Math | Raw Content1 |
| --- | --- | --- | --- | --- | --- |
| Scratch | X | X | X | X | X |
| Strikethrough | X | X | X | X | X |
| Join | X | X | X | | X |
| Insert | X | X | X | | X |
| Surround | X | X | | | X |
| Underline | X | X | X2 | | X |
| Double underline | X | X | X2 | | X |
| Slice3 | X | | | | |

### Touch gestures

| | Text Document | Text | Diagram | Math | Raw Content |
| --- | --- | --- | --- | --- | --- |
| Tap | X | | X | | X4 |
| Double tap | X | | | | |
| Long press | X | | | | |

### Smart tools

| | Text Document | Text | Diagram | Math | Raw Content |
| --- | --- | --- | --- | --- | --- |
| Typeset and Beautify | X | X | X | X | X5 |
| Intelligent Eraser6 | X | X | X | X | X |
| Lasso Selector | X7 | | X | | X |
| Move/resize selected block | X | | X | | X4 |
| Highlighter | X7 | X | X | | X |

1. Gestures are disabled by default in Raw Content but can be enabled with the raw-content.pen.gestures setting. ↩ ↩2
2. These gestures are disabled by default in Diagram but can be enabled with the diagram.pen.gestures setting. ↩ ↩2
3. The slice gesture is enabled by default but can be deactivated with the text-document.slice-gesture.enable setting. ↩
4. Requires to activate the classification/recognition with the raw-content.classification/recognition.types properties and configuration tap interaction with the interactivity customization keys. ↩ ↩2
5. Requires to activate the classification/recognition with the raw-content.classification/recognition.types properties and to tune the raw-content.convert.types property. See the raw content configuration section. ↩
6. By default, for Text, Math, Diagram and Text Document, the intelligent eraser removes any object it touches. By contrast, for Raw Content, it erases ink portions within its trajectory. In both cases, this eraser configuration can be modified thanks to the erase-precisely property. ↩
7. In all blocks of Text Document parts except Math blocks. ↩ ↩2

---

## Import and export

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/overview/import-and-export-formats/*

Import and export formats 

This page lists the available import and export formats depending on the configuration being considered.
For further explanation, refer to the import/export section of the guide.

## Available exports with Offscreen Editor

- Raw Content: JIIX, SVG, HTML.

## Available exports with Editor

- Text block: JIIX, raw text, docx1 , HTML1, PNG, JPEG
- Math block: JIIX, LaTeX, MathML2, docx1 , HTML1, PNG, JPEG
- Diagram block: JIIX, SVG, GraphML3, pptx4, docx1 , Microsoft Office clipboard format5, HTML1, PNG, JPEG
- Text Document: JIIX, raw text, docx, HTML, PNG, JPEG
- Raw Content block: JIIX, SVG, HTML, PNG, JPEG

## Available imports with Editor

- Text block: JIIX6, raw text
- Math block: JIIX
- Diagram block: JIIX7
- Text Document: JIIX6, raw text8
- Raw Content block: JIIX9

1. Direct export for the Web platform only. Native platforms are required to paste the part in an intermediate “Text Document” part to get this result. ↩ ↩2 ↩3 ↩4 ↩5 ↩6
2. A configuration property export.mathml.flavor allows you to choose between “standard” and Microsoft Office MathML. ↩
3. Deprecated as of iink SDK 2.3. A configuration property export.graphml.flavor allows you to choose between “standard” and yEd options. ↩
4. Diagram content will be exported in its converted form. ↩
5. Saved as a file at a location you define. It is up to you to place it into the clipboard using the Art::GVML ClipFormat key. Note also that Microsoft Office does not support pasting content from the system clipboard on all platforms. ↩
6. For the time being, JIIX import of text content can only be used to select recognized text word candidates, as explained here. ↩ ↩2
7. For “Diagram” parts, a configuration property diagram.import.jiix.action allows you to choose whether you want to import ink data or to change the recognition candidates. ↩
8. Raw text is imported into a “Text Document” with the addBlock method, as explained here. ↩
9. For “Raw Content” parts, a configuration property raw-content.import.jiix.action allows you to choose whether you want to import ink data or to change the recognition candidates. ↩

---

## Get started

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/ios/fundamentals/get-started/*

MyScript iink SDK makes it easy to get started.
This page helps you set up a development environment, get a certificate and play with provided example applications.

## Setting up a development environment

To develop with iink SDK for iOS, you need:

- Xcode 15.4 or later
- iOS SDK
- CocoaPods 1.14.3 or later (to retrieve iink SDK and its dependencies)
- Git (to clone the GitHub example repository)

MyScript iink SDK is packaged for iOS as a static library. Starting with CocoaPods 1.5, it is possible to use it in
combination with dynamic frameworks in your Swift application. See [this blog post](https://blog.cocoapods.org/CocoaPods-1.5.0/)for more
information. 

## Example applications

MyScript iink SDK comes with example applications illustrating how to use key APIs:

- The GetStarted example is a good starting point to discover MyScript iink SDK.
- The Demo example is a more advanced integration that you can refer too, once familiar with MyScript iink SDK.

The code is available on GitHub.

A custom compilation step will download the minimal set of recognition assets required for the example to run. More assets (e.g. to support
other recognition languages) can be downloaded from [MyScript Developer Portal](../../../../../../support/recognition-assets). 

A reference implementation for the platform-specific integration layer can be found alongside the examples. It covers aspects such as rendering
that the low-level iink SDK does not provide out-of-the-box for flexibility and portability reasons.

The source code of both the examples and the reference implementation is released under the Apache 2.0 license.
You can reuse it into your own projects without any particular restriction.

## Getting a certificate

A certificate is a binary “key” provided by MyScript that is required to enable iink SDK in an application:

- If you have just registered with MyScript Developer Portal, you should have received a certificate by mail that will let you run the provided
GetStarted and Demo examples.
- If not - or to activate iink SDK with your own applications - please follow the on-device license management instructions.

More details on certificates and license management can be found in the dedicated support section.

Developer Portal certificates are specifically generated for each app identifier. You cannot directly reuse the certificate inside your own application. 

The certificate comes embedded in a source file that you should include in your project:

- MyScript-provided examples expect it to be located at a specific location (see instructions below).
- For your own application, you can place it where you want, provided that it is accessible to instantiate the iink runtime.

## Playing with the Demo and Get started examples

To run them, just follow the following instructions:

Step 1: Clone the MyScript Git repository containing the examples for the iOS platform and navigate to the root of the folder containing the applications:

```plaintext
git clone https://github.com/MyScript/interactive-ink-examples-ios.git
cd interactive-ink-examples-ios
```

Step 2: Navigate to the root folder of the example application you want to run:

- cd Examples/GetStarted or cd Examples/Demo

Then run:

```plaintext
pod install
```

This command will use CocoaPods to fetch the iink SDK libraries.

Step 3: Replace MyCertificate.c file in the MyScriptCertificate directory with your certificate.

Step 4: Open the Xcode workspace, compile and run the default target.

---

## Instantiate Engine

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/ios/fundamentals/interactive-ink-runtime/*

Instantiate Engine 

This page shows you how to instantiate the iink runtime and configure it to fit your needs.

## Engine creation

The iink SDK runtime is represented by an IINKEngine object.

This object will let you create other key objects, configure the recognition and fine-tune the SDK behavior.

Here is how to instantiate it:

```swift
let data = Data(bytes: myCertificate.bytes, count: myCertificate.length)
guard let engine = IINKEngine(certificate: data) else {
self.engineErrorMessage = "Invalid certificate"
return nil
}
```

Data provided in parameter corresponds to your [activation certificate](../get-started/#getting-a-certificate). If engine creation fails, please make sure that it
was generated for your application identifier. 

## Configuration

A new engine must be configured to let iink SDK know which kind of content is to be recognized.

Being a flexible toolkit, iink SDK also comes with many configuration parameters.
While the default values make sense in most cases, it may sometimes be required to configure them to suit your needs.

### Accessing the configuration

MyScript iink SDK configuration is an IINKParameterSet object that can be obtained via the configuration property of the IINKEngine object.
It can be seen as a set of key/value pairs, where values themselves can be other IINKParameterSet objects.

You can read the value attached to an existing key, add new (key, value) pairs or remove existing ones.
Supported value types are strings, numbers, booleans, arrays of strings, as well as other IINKParameterSet objects.

It is possible to attach a delegate implementing the IINKConfigurationDelegate protocol to a given configuration object to get notified when configuration
changes are made.

### Configuring the recognition

To recognize math, shapes or text in any language, the engine needs to be created and pointed to the required assets.

Assets packages consist in a set of configuration files (*.conf) that specify required recognition parameters combined to binary files called resources files (*.res).
The resources files host everything that the engine requires for the recognition.

MyScript iink SDK default configurations should be suitable for most needs. So in most cases, you don’t have to care for them.
If you need to go further, you can learn how to modify or write your own configuration files (advanced).

Make sure to properly deploy these files along your application as well. A good practice is to implement [error management at editor
level](../editing/#monitoring-changes-in-the-model)to be notified of recognition configuration error. 

### Language recognition configuration

Default language for text recognition is en_US english. So one of the first recognition tuning you might want to do is modifying the language.

MyScript language names start with a two-letter language code (using the [ISO-639 standard](https://www.iso.org/iso-639-language-codes.html)),
followed by an underscore and a two-letter country code (using the [ISO-3166 standard](https://www.iso.org/iso-3166-country-codes.html)).
For example *en_US*for US English. 

MyScript delivers some ready to use language packs so that updating language is an easy task that you can perform in a few steps:

Step 1 Download the corresponding language pack, so in our example, select the italian language:
Packs for additional languages or content types are available on MyScript Developer Portal.

Step 2 Install the pack in your application project:
The language pack consists in a *.zip archive containing a configuration file (*.conf), and associated resources files (*.res) to be extracted in your project path.

Make sure to properly deploy these files as the .conf file refers to the .res files with relative paths. So take care to keep the archive folder structure when extracting the files 

Step 3 Modify the engine configuration language in you application code:

- Set the value of the configuration-manager.search-path key to the folder(s) containing your language configuration file(s) (*.conf).
- Set the value of the lang key to match your language

For instance, set it_IT for the Italian language, as corresponding resources are described in it_IT.conf:

```swift
var configuration = engine.configuration;
let configurationPath = Bundle.main.bundlePath.appending("/recognition-assets/conf")

// Tells the engine where to load the recognition assets from.
configuration.set(stringArray: [configurationPath], forKey: "configuration-manager.search-path")

configuration.set(string: "it_IT", forKey: "lang")
```

When using [Recognizers](../../advanced/recognizers/#text-recognizer), the language configuration key should be prefixed by `recognizer`. 

### Content-specific configuration

MyScript iink SDK comes with many configuration options. Some are general, like the ability to choose the location of the temporary folder
to store work data on the file system, and some depend on the type of content you manipulate. For instance, it is possible to activate or deactivate the solver
for math equations.

The full list of supported configuration options can be found in the dedicated section.

### Editor-level or Recognizer-level configuration

Engine-level configuration corresponds to the default, global configuration. It is possible to override configuration values at
editor-level or recognizer-level which is useful if you manage several parts or recognizers with different configurations.

Injecting configuration at the editor level is also very convenient when working with a “Raw Content” content type, because this content type is flexible and allows specific behaviors according to its editor configuration:

- This text_math_shape.json is intended to take advantage of interactivity with our latest analyzer and engine.
- This interactivity.json can be used to have interactivity with our legacy analyzer and engine.
- While this drawing.json configuration illustrates how to do some drawing without any classification or recognition.

To avoid any side effects when injecting a configuration JSON, it is recommended that you first reset the configuration to its defaults:

```swift
// retrieve editor current configuration
let conf: IINKConfiguration = editor.configuration
// resets this configuration to its default values.
try? conf.reset()
// Injects the content of a JSON into this configuration.
try? conf.inject(myconfigurationJSON)
```

To restore your part configuration after reopening its package, you can save it in its [metadata](../storage/#metadata).

---

## Recognizer

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/ios/advanced/recognizers/*

Recognizers 

The recognizers aim at performing real-time incremental recognition on transient ink.

## Setup

In order to use the recognizers, you need to:

- Create an IINKEngine object.
- Set the value of the recognizer.configuration-manager.search-path key to the folder(s) containing your Recognizer configuration file(s) (*.conf).
- Create your IINKRecognizer object by indicating its type (either Text, Shape, Math, Raw Content or Gesture), and can then send PEN events to it.
- You should add a IINKRecognizerDelegate delegate to the IINKRecognizer. When a recognition result has changed, an event notifies the IINKRecognizerDelegate with the resultChanged method. When an error occurs during the recognition process, an event notifies the IINKRecognizerDelegate with the onError: method.

## Configuration

### Text Recognizer

- The recognition configuration for the Text Recognizer is based on the same principles and language resources as the Engine configuration, except that it uses dedicated configuration keys with a recognizer. prefix :
For instance, recognizer.lang is used to configure the recognition language.
- By default, text guides are disabled, but you can enable the guides of a Text Recognizer via the recognizer.text.guides.enable key. In addition, you can tune their spacing and start origin.
- By default, the Text Recognizer recognizes both “classical” handwriting, whether print or cursive. But its configuration can be changed to recognize superimposed handwriting: To learn more, check MyScript ready-to use resources section.

### Gesture Recognizer

Supported gestures are defined thanks to recognizer.gesture. prefixed keys.

### Shape Recognizer

- To use the Shape Recognizer, you must deploy the shape resources in your application. They are contained in the myscript-iink-recognition-shape.zip package.
- By default, the shape beautification is enabled: the beautification process consists in aligning shapes with each other, connecting shapes that almost touch each other and scaling shapes having close sizes.
You can disabled the shape beautification with the recognizer.shape.beautification.enable.

### Math Recognizer

- To use the Math Recognizer, you must deploy the corresponding Math resources in your application. They are contained in the myscript-iink-recognition-math2.zip package.
- Default Math resources are generally sufficient for most needs. However, in some cases, it may be necessary to use only a subset of Math symbols or rules. You can learn how to build your own resources files.

Currently, the Math Recognizer may not be available on your platform. [Check](../../../overview/platforms/)if it is available for your platform. 

### Raw Content Recognizer

To use the Raw Content Recognizer, you must:

- Deploy the document layout analysis resources that are contained in the myscript-iink-recognition-raw-content2.zip package.
- Define the classification configuration of your Recognizer with the recognizer.raw-content.classification property according to your needs, to control the list of content types that can be identified by the ink strokes classifier.
- Define the recognition configuration of your Recognizer with recognizer.raw-content.recognition, to control the list of content types that are recognized after classification.
- If you want to perform text recognition, define your recognition language with the recognizer.lang property.
- Deploy the resources packages according to your recognition configuration:

In addition to the myscript-iink-recognition-raw-content2.zip package, the following table lists resources that you must deploy in your project according to the recognition types that you use:

| Recognition content type | Required configuration bundles | Resource and configuration package names |
| --- | --- | --- |
| text | ${recognizer.lang} | Language package defined by your recognizer.lang configuration. See principles of language resources |
| math | math2 | myscript-iink-recognition-math2.zip |
| shape | shape | myscript-iink-recognition-shape.zip |

Currently, the Raw Content Recognizer may not be available on your platform. [Check](../../../overview/platforms/)if it is available for your platform. 
- Classification and recognition results are available in JIIX format.
We have added an export.jiix.ranges parameter that allows you to get ink ranges corresponding to result objects in the JIIX result file.
It is theoretically possible to do this matching by enabling export.jiix.strokes, but then you will have to match the input strokes by their channel values, which can be tricky.
Also, export.jiix.strokes produces huge JIIX output while export.jiix.ranges is much more concise.
So when using a Raw Content Recognizer, we recommend you to set export.jiix.strokes to false and export.jiix.ranges to true.

➤ For more details, refer to the configuration and jiix pages.

### Common parameters

- recognizer.result.default-format defines the format of the result provided via the IINKRecognizerDelegate resultChanged method.
To get the available list of formats, use the IINKRecognizer supportedResultMimeTypes method.
- When performing batch recognition, it is now possible to configure the maximum number of threads to be used by the engine for Text and Math Recognizers,
by setting max-recognition-thread-count configuration value to the number of threads to be used (default is 1).
This tuning might be relevant when sending at one time, a large set of strokes that you have previously collected, to optimize the usage of CPU cores.
It is advised however, to leave this configuration to 1 if you are doing incremental recognition, as it may have a negative impact on performances and accuracy.

➤ Refer to the configuration page, to get the full list of recognizer configuration.

## Example

The write to type example gives you a hint how to implement scribble like feature relying on the Recognizer API of iink SDK.
It is available on the MyScript Git repository containing the additional examples for the Android platform.

This sample is for Android, but it comes with [a description](https://github.com/MyScript/interactive-ink-additional-examples-android/blob/master/samples/write-to-type/ReadMe.pdf)that helps you understand its principle and that you can apply to other platforms. 

It is based on a contextless gesture recognition combined with a text recognition.
To run both recognitions simultaneously, two instances of Recognizer are created - one for Gesture recognition and the other one for Text recognition.

➤ Should you need more details, refer to the API documentation and/or ask question on our developer forum.

---

## Interactivity specific

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/ios/advanced/non-interactive-languages/*

Non-interactive languages 

This page explains how some additional languages can be handled by iink SDK in non-interactive mode only.

This page list the languages that currently don’t support interactive features provided with OffscreenEditor and Editor integrations.
They are available for Recognizer integrations:

- Arabic
- Farsi - Iran
- Hebrew - Israel
- Hindi - India
- Thai - Thailand
- Urdu - Pakistan
- Vertical Japanese - Japan: vertical writing is supported by using dedicated resources.

---

## Storage

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/ios/fundamentals/storage/*

Storage 

This page explains how iink SDK lets you organize the data it works on, store content and load it again later.

## Structure of the model

MyScript iink SDK stores content using the following structures:

- IINKContentPackage - A Package is a container storing ink and its interpretation as an ordered collection of parts. It can be
saved as a file on the file system and later reloaded or shared between users.
- IINKContentPart - A part corresponds to a standalone content unit that can be processed by iink SDK.
Each part has a specific type, corresponding to the type of its root block, that can be retrieved via its type property.

The complete list of supported part types can be found [here](../../../overview/content-types/). 

It is possible to get the number of parts of a given package via its partCount property and access an individual part by calling part and pass it
the 0-based index of the part to load.

Parts host the data iink SDK works on. As a result, it is required to use them even if you do not intend to persist data on the disk as part of your
application workflow.

Although a content part sometimes hosts a single [content block](../block-selection-management/), both concepts are not equivalent. A part corresponds to a *serialization*unit, while a block corresponds to a *semantic*unit that can be manipulated. 

## Working with packages

MyScript iink SDK uses the file system to limit the amount of RAM that is required at a given point in time, as well as to store temporary files.
It also provides serialization/deserialization methods to let application save/load MyScript data, either for persistence needs or to exchange it between
users.

MyScript iink SDK serialization format is optimized for speed and compactness, but is not easily readable. If you want to parse the content
of the interactive model, refer to the [import/export section](../import-and-export/). 

### Temporary folder

Even if you do not intend to explicitly save any content, MyScript iink SDK requires a read/write access to at least one folder on the
file system: the temporary folder, where it will output the intermediate files it is working on.

By default, iink SDK uses the folder where the package file is located. It may however be relevant (and even mandatory on certain platforms) to choose
another folder. This can be achieved by setting the value of content-package.temp-folder in the configuration of the engine.

If it does not exist, the folder will be created if you [save](#saving-packages)the corresponding package.
It may also be automatically created by iink SDK in case it has a need to reduce its memory usage or when handling some particular objects such as
images. 

### Creating and loading packages

To create or open packages, use the openPackage:openOption:error: method. It comes with different possible options:

- IINKPackageOpenOptionExisting to open an existing package and fail if it does not exist (default behavior).
- IINKPackageOpenOptionCreate to open an existing package or create it if it does not exist.
- IINKPackageOpenOptionCreateNew to ensure to create and open a package that did not previously exist.
- IINKPackageOpenOptionTruncateExisting to create and open a new package, overwriting any pre-existing package at the same location.

To create a new package, you can alternatively call the createPackage:error: convenience method, which is equivalent to call
openPackage:openOption:error: with the IINKPackageOpenOptionCreateNew option.

Both methods take as their first parameter the name of the file corresponding to the package on the file system.

```swift
// Create a new package
var newPackage = engine.createPackage("newPackage.iink")

// Load an existing package
var existingPackage = engine.openPackage("existingPackage.iink")
```

### Saving packages

MyScript iink SDK provides two distinct methods to save content:
saveWithError: and saveToTempWithError:, both to be called on the IINKContentPackage instance to consider.

It is important to understand the distinction between them, as they play different roles:

- saveWithError: will serialize all data into a zip archive named after the package, whether such data is on the memory or if it was off-loaded into the
temporary folder. The resulting file is self-contained, and can be reloaded at a later point. Due to the compression, this method is rather slow.
- saveToTempWithError: will save the content that was loaded into the memory to the temporary folder. As it only writes the content that was in the
memory at a given point in time and does not require compression, calling this method is much faster. It can let iink SDK recover such data if it was
forced to exit without saving to the compressed archive.

The following diagram explains how iink SDK manages the memory, as well as the role of the different save operations:

ContentPackage “content.iink” (in RAM)content.iink(zip archive)Temporary foldercontent.iink-filesfragment 1fragment 2fragment 3first “save”create archive and commit content“open”partial extraction“saveToTemp”off-load memory<automatic>partial extraction<automatic>partial loador off-load“save”commit changes By default, data corresponding to a content package is stored in a folder named after this package by appending the `-files`suffix and
located in the same folder. 

### Deleting packages

Use the deletePackage:error: method to remove an existing package from the disk. Make sure to first release all references to this package, including
parts you opened.

## Working with parts

Parts are created and manipulated from their parent package.

### Creating parts

To create a part, call createPart on the parent package and pass it a string corresponding to the content type you want to assign
to its root block (it cannot be changed afterwards).

Possible options are currently “Text”, “Math”, “Diagram”, “Raw Content” or “Text Document” (case sensitive).

To copy a part from an existing package, call clonePart on the destination package (which can be the same as the origin package if you just
want to duplicate the part) and pass it a pointer to the part to copy.

To “move” a part from a package to another, first clone it into the new package and then delete the part from the original package.

### Opening parts

To open a part, call part and pass in parameter its index in its parent package (indexes start at 0). The number of parts of a given package
can be retrieved via its partCount property.

### Deleting parts

To delete a part, call removePart on its parent package.

## Metadata

You can attach metadata to both IINKContentPart and IINKContentPackage objects, and they will be serialized with the file.
This can prove useful to store client-specific parameters.

Use the metadata property to store and retrieve the metadata attached to the object.

```swift
// Retrieve the metadata from a part
let metadata = part.metadata

// Set and Get (key, value) pairs
...

// Store the metadata back into the part
part.metadata = metadata;
```

The structure representing metadata is an IINKParameterSet and is manipulated the exact same way as engine configuration parameters.

---

## Math interactive features

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/overview/math-features/*

Math interactive features 

To see the complete list of supported symbols, rules and operations, read this section.

## Math solver

MyScript iink SDK not only recognizes equations, it can also solve some of them!
Its arithmetic solver can solve input equations under the following conditions:

- The equation has to contain numbers and/or fractions, and at least one of the following operators or constants:

- Equations with one unknown can be solved. The way variables are managed depends on the part type, as explained in the next section.
- Equations with more than one unknown can be recognized and typeset, but not solved.

In a Raw Content part, the solver can also:

- Solve vertical operations using a single operator per line [+-*×/:÷] and decimal numbers, by drawing a line underneath.
- Provide the correct result for expressions such as cos(60°), 0.5 in this case, by considering the annotated value in degrees regardless of the math.solver.angle-unit configuration (rad or deg).
When math.solver.angle-unit is set to rad, an automatic unit conversion occurs when writing expressions such as 60° =, which is solved as its radian value (1.047197).

### Manual or automatic solver

You can either choose to add a button so that your user will activate the solver manually or to have your app automatically solve every supported equation.
Just choose what is more appropriate to your use case!

### Customize your output

You can choose the angle unit (degree or radian), how many decimals you want displayed and whether you want results to be rounded or truncated.
You can also decide to insert implicit multiply operators, perform syntactic correction or whether an equal sign should be present to trigger the solving.

➤ Refer to the math.solver. configuration settings to see what you can control with the numerical computation action of the math solver.

## Math solver in a Math part or Text Document part

By default math solver is activated but you can disable it.

- When math solver is activated, converting the math will trigger solving, if the required conditions are
in place.
Equations with one unknown can be solved, but the variable has to be highlighted with a question mark, not a letter.
Example: “4y × 2 = 24” won’t be solved whereas “4 × ? × 2 = 24” will.
- MyScript iink SDK can also perform math animation (morphing) when converting math strokes to typeset.
By default this feature is disabled but can be set up with the math.convert.animate property.

## Math solver in a Raw Content part or block

To use the features described in this section, you must configure your Raw Content part with [the advanced analyzer raw-content2 and math2 bundles](../content-types/#raw-content-analyzer). 

The MathSolverController object is the entry point for interacting with your math content in a "Raw Content" part or block with Editor and OffscreenEditor.

### Variable management

The MathSolverController manages variables in mathematical expressions: variables are single letters, either Latin or Greek, with an optional subscript, which can be a positive integer or another Latin or Greek letter.

Variable management can be:

- Automatic meaning that a variable definition is automatically recognized and applied by the iink SDK when a block contains an equation with only one variable on the left of the equal sign
and an expression that can be calculated on the right. Examples: “a = 24” or “a = 2 + 3/4”.

It can contain multiple equal signs, such as: “a = 1/2 = 0.5” .
In the case of an inequality, the variable is defined using the first value. For example, “a = 5 = 6” defines “a = 5”.

The right expression can refer to other variables defined for this block: Example: “a = 3b”.
The asVariableDefinition method checks to see if the specified block is a variable definition and returns the information about it.

By default, automatic variable management is disabled, you can enable it with the `math.solver.auto-variable-management.enable`property. 
- Manual meaning that variables that apply to a particular math block are managed by programmatically calling getVariableValue, setVariableValue and removeVariableValue methods of the MathSolverController. You can set or retrieve the values of global variables that apply to all blocks by setting an empty string as the block ID.
- If you enable automatic variable management, you can also use the manual APIs to set some variables or domain constants for example.

API defined variables for blocks will apply with higher priority over automatically recognized ones, which have priority over global variables. 

The getVariables method gets information about all variables globally or associated with a given block.
The getVariableDefinitions method lists all variable definitions, including their source type and associated block.

### Evaluation of a block expression to get plot-ready coordinates

The MathSolverController has an evaluate method to calculate the outputs of an evaluable math block expression, for a given range of input values.
This allows you to get plot-ready coordinates that you can use to plot graphs using a graphics library.

An expression is evaluable if it can be interpreted as a function of a given variable:

- The expression can be a simple expression with a single unknown variable Example “cos(x)”, in which case the output variable will have an empty name.
- It can also be an equation with two unknown variables, at least one of which occurs only once in the expression Example “y = x² + 2x”.
- Or a constant expression with a single unknown variable Example “y = 4/3”, in which case the input variable will have an empty name.

The getEvaluables method returns the list of evaluable variables for a “Math” block.

### Get the solver output

The MathSolverController can

- list the available solver actions with the getAvailableActions method (currently only numeric calculation is available),
- get the solution result as a LaTeX or JIIX string with the getActionOutput method.
- add the solution output to the math block in the current Content Part with the applyAction method (currently only available with the Editor).

### Diagnostics and troubleshooting

To help you troubleshoot common pitfalls, the getDiagnostic method performs diagnostics on a given task and the specified block. It can be useful for:

- Understand why getEvaluables() returns an empty array, by calling it with an evaluation task.
- Find out why getAvailableActions() does not include the numerical-computation action in the returned array, by calling it with a numerical-computation task.

The getDiagnostic also returns a MathDiagnostic code so that your application can get information about error situations, such as computation errors, and that you can map to a localized error message in your application to let end users know what’s going on.

---

## Combined undo/redo stacks

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/ios/advanced/combined-undo-redo-stacks/*

Integrate with the undo/redo stack of your application 

This page explains how you can make iink SDK operations part of the undo/redo stack of your application.

## Use case

If your application is based on an iink SDK editor, undo/redo management is available out of the box, as shown in the editing part of the guide.

Chance is, however, that your application is more complex, and that you may need to integrate iink SDK operations into your own undo/redo stack.

## Conceptual undo/redo stack

The application undo/redo stack can be seen as a vector of states, each but the first resulting from a specific operation.

In the following example, the current state is ⑤ and results from applying operation op5 to the previous state ④:

12345op1op2op3op4op5current 

Calling undo reverts the effect of the last operation. It is equivalent to moving from the current state in the stack to the state on its left.

In the example, if the current state is ⑤, two successive undos lead to state ③:

12345op1op2op3op4op5current 

You can notice that states ④ and ⑤ are still part of the stack. This is because no new state was created and it shall thus be possible to redo.

Calling redo applies the next operation on the stack. It is equivalent to moving from the current state in the stack to the state on its right.

In the example, if the current state is ③, a redo will move back to state ④:

12345op1op2op3op4op5current 

If a new operation op6 is performed from state ④, the resulting state ⑥ becomes the new current state, and state ⑤ is gone from the stack:

12346op1op2op3op4op6current 

## Including iink SDK operations

It may be required for the application integrating iink SDK to mix its own operations with those managed by iink SDK.

For instance, the application may add an image to a layer below an iink SDK text block, add a stroke to the text block, and finally select and delete the image.
The expectation at this point is that if the user presses two times the undo button, the first press brings the image back and the second removes the stroke that was sent to iink SDK.

Situation before the user presses undo:

123add imageiink opdeleteimagecurrent 

Situation after the first undo:

123add imageiink opdeleteimagecurrent 

Situation after the second undo:

123add imageiink opdeleteimagecurrent 

The application needed to include and manipulate the effects of iink SDK operations.

iink-resulting states are shown with a blue background in the different examples. 

## Managing iink SDK operations

The challenge is that iink SDK maintains its own internal undo/redo stack and that the host application does not have access to the operations it contains. It
is however possible to query iink SDK to get information about the state of its internal stack to implement the desired behavior.

From now on, you should consider that the application does not know exactly what the iink operations actually do (it actually does not matter). Let’s show how
it can still properly manage its undo/redo stack.

Let’s go back to the example. How to obtain this stack?

123add imageiink opdeleteimagecurrent 

The iink SDK editor has the following properties:

- undoStackIndex - The position of the cursor identifying the current state in the internal iink undo/redo stack.
- possibleUndoCount - The number of operations that it is currently possible to undo (thus possibleUndoCount ≤ undoStackIndex).

You can know when iink SDK adds new “undoable” operations by watching the increments of undoStackIndex. You can compare a previously stored value with the one returned by calling undoStackIndex after a contentChanged notification.

Let’s see how it applies to the example. Let’s consider that you have set up an iink SDK editor and attached a “Text” part to it. As nothing was done,
undoStackIndex equals to 0. First, you add your image.
As it is done outside of iink SDK, contentChanged is not called and undoStackIndex does not increment.

The application and iink SDK editor stacks respectively look as follows:

1add imagecurrentcurrentApplication:iink Editor:stackIndex = 0 

You now send a stroke to the iink SDK editor.

You may get one or more contentChanged notifications and test for undoStackIndex increments. If the
stroke is not discarded as a gesture (it shouldn’t!), undoStackIndex is incremented:

1add imagecurrentcurrent1iink opApplication:iink Editor:stackIndex = 1 

As you know that iink SDK internal stack added a new state. You can add a new state to the application stack corresponding to the effect of an opaque iink
operation:

12add imageiink: “1”currentcurrent1iink opApplication:iink Editor:stackIndex = 1 

The value of undoStackIndex obtained after the iink operation is stored into the application stack.
It is useful to be able to see whether the value you get from contentChanged notifications has changed and to react accordingly.

You can now select and delete your image outside of iink SDK.
Like for the first operation, contentChanged is not called and undoStackIndex is not incremented:

123add imageiink: “1”deleteimagecurrentcurrent1iink opApplication:iink Editor:stackIndex = 1 

Now, let’s undo. As the current application state results from an application-level operation, it is up to the application to restore the image:

123add imageiink: “1”deleteimagecurrentcurrent1iink opApplication:iink Editor:stackIndex = 1 

Let’s undo again. The current state results from an internal iink SDK operation.
One should thus call undo on the iink SDK editor when moving the cursor on the application stack:

123add imageiink: “1”deleteimagecurrentcurrent1iink opApplication:iink Editor:stackIndex = 0 

Now, if you wanted to redo, you would first call redo on the iink SDK editor and move the cursor to the right,
as the operation to redo was an iink operation (undoStackIndex
is incremented to 1 but as it comes from a redo operation, you should not consider it as a new operation that would prevent a
next redo by clearing the stack). Redo again and this time manage the image deletion on the application side.

The iink SDK undo stack is partially purged from time to time to control memory consumption.
As a result, it may sometimes not be able to revert all the states that were are known by the application-level stack.
To know if an undo is actually possible, you should check the value of `possibleUndoCount`, that tells you how many steps can be undone by iink SDK from its current internal state. 

## Managing several iink SDK editors

Each content part has its own undo/redo stack. As a result, if you work with multiple iink SDK editors, you must associate each iink undo/redo operations to an
editor, so that you know which editor should perform the undo or redo operation referenced in your application-level stack.

---

## OffScreenEditor specific

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/ios/advanced/off-screen-usage/*

OffscreenEditor 

This page explains how you can use interactivity without using iink SDK rendering.

## Offscreen Interactivity use case

Up to iink SDK 2.0, it was necessary to use the iink SDK rendering in order to benefit from iink SDK interactive features.
In 2.1, while keeping our classical Editor and its related objects and interfaces,
we introduced the Offscreen Interactivity feature based on an OffscreenEditor.

Application iink SDK Strokes Result exports Incremental processing Data model iink model Gesture analyse Gesture notification Capture 

This OffscreenEditor lets you programmatically drive the content model update by keeping the incremental recognition principle and using gesture notifications.
The application can rely on its own rendering to manage the captured strokes and display its model.
Recognition results are available on demand with dedicated APIs.

### Offscreen Interactivity main objects

The OffscreenEditor is only available for “Raw Content” parts, but the high flexibility of “Raw Content” allows many specific behaviors depending on its configuration as described here.

It relies on these new objects and interfaces:

- OffscreenEditor is a service allowing offscreen interactivity. It is the entry point to edit an associated part and receive change notifications.
- ItemIdHelper allows working with item IDs (i.e. strokes). It is associated with an OffscreenEditor.
- IOffscreenEditorListener the listener interface for receiving OffscreenEditor events.
- IOffscreenGestureHandler The listener interface for handling gesture events.

### Offscreen Interactivity undo/redo

- HistoryManager gives you access to undo/redo stack manipulation, just like the legacy Editor and content of changesets. The goal of the HistoryManager is to allow you to use undo/redo to preserve text recognition, rather than redoing strokes, which can change stroke order and recognition output.
- To help you synchronize your undo stack with ours, we also give you access to changesets, so you can know what our next undo/redo will do. A changeset contains N ChangesetOperation which each corresponds to an operation (ADD, ERASE or TRANSFORM) on a list of item IDs.
- For performance reasons, a HistoryManager is associated with an OffscreenEditor on creation, only if offscreen-editor.history-manager.enable is set to true (by default this parameter is false).
It can then be accessed with OffscreenEditor getHistoryManager() method.

### Math usage helper

When you configure your OffscreenEditor to classify and recognize math content in your “Raw Content”, the MathSolverController object is the entry point for interacting with your math content.

The default Math solver configuration associated with OffscreenEditor ensures that strokes generated by the MathSolverController and their bounding box are provided without any additional configuration when requesting the JIIX action output of the MathSolverController.
When users write the equal sign at the right end of the equation, the bounding box and the strokes of the result can be retrieved easily by parsing the JIIX returned by the getActionOutput method.

### Improve user experience

Sometimes, the block extraction or ink classification does not give the expected result, leading to a degraded user experience with some ink recognized as text instead of shape, or shape as drawing, etc.

In order to cope with such a situation, you can force a set of items to be classified as a specific type and/or grouped them with the OffscreenEditor setItemsType().
The getAvailableItemsTypes() returns the list of possible types for a set of item ids.

## Offscreen Interactivity API and samples

The offscreen-interactivity sample is an Android sample which shows how to integrate MyScript iink SDK interactivity with your own rendering.
It drives the content model by sending the captured strokes to iink SDK and keeps the incremental recognition principle and gesture notifications.
This sample uses a third-party rendering library to manage the captured strokes and display its model, and get real-time recognition results and gesture notifications.

Although this kotlin example is for Android, it can serve as a source of inspiration for other platforms and languages, as the principle is the same. 

➤ For more details, refer to the API documentation and/or ask question on our developer forum.

---

## Editor specific

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/ios/fundamentals/rendering/*

Rendering 

This page provides an introduction to the way iink SDK manages the rendering.
You will learn how to use the reference implementation provided by MyScript and properly plug things together.

## Key concepts

With these concepts, you will be able to better understand how to use the reference rendering implementation or build your own (not
documented yet).

### Render target

A render target (adopting the IINKIRenderTarget protocol) represents the platform “view” where the drawing operations will occur.

### Canvas

A canvas object provides a platform implementation of the drawing commands called by iink SDK to render content. It is defined by the IINKICanvas protocol.

### Renderer

A renderer is a component in charge of deciding how to render content of each layer, knowing which area of the model needs to be refreshed, as well as
parameters such as zoom factor or view offset. It will issue rendering commands, through a canvas object that will do the actual
drawing operations.

Version 1.4 introduced a new rendering capacity for the renderer based on the drawing of offscreen surfaces.
This increases the rendering speed and is even necessary for new features like math animation. So it is definitively our recommended choice.

To use this rendering, you must adopt the IINKIRenderTarget and IINKICanvas protocols, or use the ones provided with the reference implementation, to handle the drawing requests of offscreen surfaces.

The iink SDK 4.2 renderer is still compatible with the legacy rendering mode that we name “direct rendering”.

### Layer

For performance reasons, the renderer works on two different layers.

The [reference rendering implementation](#reference-implementation)implements these layers for you. However, you may sometimes need to interact
with them. 

The two layers are:

- A model layer, corresponding to everything in the model that was already processed by the engine (guidelines, strokes, images, typeset text, …),
- A capture layer, rendering the ink drawn on the screen but not yet processed by the engine.

Each layer can be refreshed independently from the other, so that it is not needed to redraw everything.

### Ink prediction

An ink prediction mechanism is available that allows bridging part of the gap between the pen and the ink, but may trigger some visual artifacts.
This mechanism is available with two configuration properties:

- a boolean renderer.prediction.enable (default value is false)
- a number renderer.prediction.duration that represents the targeted prediction duration in ms (default value is 16 ms, max is 200 ms).
A 16 ms prediction corresponds to one rendered frame on a 60Hz device screen.
Higher durations are possible but might reduce prediction accuracy or stability, depending on your device input sampling frequency or screen refresh rate.
Value should be tuned to avoid unwanted visual artifacts and guarantee the best user experience.

By default, ink prediction is disabled in the SDK, but all Demo examples enable prediction duration at 16 ms, which is a good compromise to avoid visual artifacts.
So, if you want to evaluate the ink prediction mechanism, you can draw on Demo examples to learn how to do it.

### Additional brush implementation

The iink SDK supports additional brushes based on APIs that rely on OpenGL for advanced rendering styling, such as the Pencil brush.

While these new iink APIs are cross-platform (and backward compatible), they are currently only implemented for Android. 

### Applying pressure, tilt, and orientation effects to rendered strokes

When digital pens provide pressure levels, tilt and orientation angles in the input pointer events for the Editor, our Renderer adjusts the stroke rendering depending on the styling CSS properties.

## Reference implementation

To make it easy to build applications, MyScript provides in its examples repository a default rendering implementation.

It is released as a library, under a permissive license and can be reused as-is or modified should you feel the need.
As an integrator, you just have to link against it and do a bit of plumbing:

1. Instanciate an EditorViewController object
It is a ready-to-use implementation of a render target, with layered rendering and integrated canvas for drawing operations.
2. Inject the EditorViewController in any Container you like

The goal of the next step of this guide is to explain how to add some content to the model.

---

## Editing

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/ios/fundamentals/editing/*

Editing 

This page introduces the role of the IINKEditor object, the central point to interact with content.

## Editor creation and configuration

### Creation

An IINKEditor is the main entry point to act on interactive content.
It is responsible for building and updating a content model from users’ input events and/or edition commands.
It is instantiated from an IINKEngine object:

```swift
//create the Editor
let editor = engine.createEditor(renderer: renderer, toolController: toolcontroller)
```

The ToolController argument is optional. If you omit it, the editor will instantiate a ToolController with the default settings.

If you use the reference implementation, the `EditorViewModel`will create the editor automatically for you. 

### Editor-level configuration

While iink SDK can be globally configured at engine level, it is possible to override this configuration at editor level. This is
particularly useful in form-like use cases, where you need to manipulate fields with different configurations.

You can access the configuration of a specific editor via the configuration property and set the values of the keys that should override the global
configuration, in a cascade-like manner. Values of the keys you do not explicitly set at editor-level still follow engine-level configuration.

For example:

```swift
let globalConfig = engine.configuration
let editorConfig = editor.configuration

// Global configuration values apply ...
var globalUnit = globalConfig.string(forKey: "math.solver.angle-unit") // -> "deg"
var editorUnit = editorConfig.string(forKey: "math.solver.angle-unit") // -> "deg"

globalConfig.set(string: "rad", forKey: "math.solver.angle-unit")
globalUnit = globalConfig.string(forKey:"math.solver.angle-unit") // -> "rad"
editorUnit = editorConfig.string(forKey: "math.solver.angle-unit") // -> "rad"

// ... except if overridden at editor level
editorConfig.set(number: 4, forKey: "math.solver.fractional-part-digits")
globalConfig.set(number: 2, forKey: "math.solver.fractional-part-digits")

var editorDigits = editorConfig.number(forKey: "math.solver.fractional-part-digits", defaultValue: 3) // -> 4
var globalDigits = globalConfig.number(forKey: "math.solver.fractional-part-digits", defaultValue: 3) // -> 2
```

Language-related settings like `text.configuration.bundle`and `text.configuration.name`behave in a particular way, in that they are only
considered the very first time a given part is set to an editor and cannot be changed afterwards. 

### Setting a part

An IINKEditor works on an IINKContentPart.
To setup the link between them, call the editor’s part property and pass it the part you opened or created:

```swift
//create the content Package
contentPackage = engine.createPackage(packageName)

//create the content part
contentPart = contentPackage.createPart(with: partType)

//set the part to the editor
editor.part=contentPart
```

You have to make sure that you previously called `setViewSize:`on the editor and attached to it a [font metrics provider](../conversion/#computing-font-metrics)before setting the part. If you use the reference implementation, the `EditorViewModel`will do it automatically for you. 

### Guides

Text Document and Text parts have guides set by default. Guides provide useful hints for end users to know where to write and at what size. They also
improve the recognition accuracy, provided that handwriting uses them as baselines.

You can enable or disable the guides of a Text part via the text.guides.enable key of the engine or
editor configuration. The vertical spacing between guides can be tuned via the text styling options.

If you know that your input will not match the guides, for instance with ink coming from an unstructured context such as a sheet of
paper, you must disable them to ensure a good recognition. 

## Input capture

You are in charge of capturing the input events.
This section gives you some hints on how to transmit the captured inputs to the editor.

### Incremental input

MyScript iink SDK typically processes user input in real time.
You thus have to tell how pointers are interacting with the capture surface (typically a screen or a graphical tablet).

This can be done by calling the following methods of the IINKEditor object:

- pointerDown(point:timestamp:force:type:pointerId:) - When the pointer first touches the surface.
- pointerMove(point:timestamp:force:type:pointerId:) - When the pointer moves while staying in contact with the surface.
- pointerUp(point:timestamp:force:type:pointerId:) - When the pointer is lifted from the surface.

Each of these methods requires you to provide:

- x and y - The coordinates in pixels of the pointer on the surface.
- t - The timestamp of the pointer event
- f - The pressure information associated to the event (normalized between 0 and 1)
- type - The type of pointer: see the IINKPointerType
- pointerId - An identifier for this pointer.

Example:

```swift
editor.pointerDown(point: CGPoint(x: 0.0, y: 0.0), timestamp: Int64((Date().timeIntervalSince1970 * 1000.0).rounded()), force: 0.7, type: IINKPointerType.pen, pointerId: 0)

editor.pointerMove(point: CGPoint(x: 1.4, y: 2.4), timestamp: Int64((Date().timeIntervalSince1970 * 1000.0).rounded()), force: 0.6, type: IINKPointerType.pen, pointerId: 0)

editor.pointerUp(point: CGPoint(x: 2.4, y: 4.2), timestamp: Int64((Date().timeIntervalSince1970 * 1000.0).rounded()), force: 0.5, type: IINKPointerType.pen, pointerId: 0)
```

You can call `pointerCancel:error:`to have the editor drop and ignore an ongoing event sequence. 

Remarks:

- The pointer events are analyzed and interpreted according to the tool that is currently associated to the pointer type:
when using the PEN tool, iink SDK triggers the recognition, with the SELECTOR tool iink SDK determines a selection, etc.
- The timestamp is typically the time in ms since Jan 1st, 1970.
You can set it to -1 to let iink SDK generate one for you based on the current time of the system.
- The pressure information is stored in the model and can be retrieved at export or when implementing your own inking.
If you don’t have or need this information, you can set it to 1.
- If you only have one pointer simultaneously active, you can pass a pointer id of -1.

In the most simple case, you can write something like:

```swift
editor.pointerDown(point: CGPoint(x: 0.0, y: 0.0), timestamp: -1, force: 0, type: IINKPointerType.pen, pointerId: 0)

editor.pointerMove(point: CGPoint(x: 1.4, y: 2.4), timestamp: -1, force: 0, type: IINKPointerType.pen, pointerId: 0)

editor.pointerUp(point: CGPoint(x: 2.4, y: 4.2), timestamp: -1, force: 0, type: IINKPointerType.pen, pointerId: 0)
```

The same methods exist with two additional parameters:

- tilt - the tilt angle to the screen in radians. Angles are between 0 and π/2 radians, where 0 is perpendicular to the screen, π/2 is flat on screen.
- orientation - the orientation azimuth in radians, where 0 is pointing up, -π/2 radians is pointing left, -π or π is pointing down, and π/2 radians is pointing right.

If available, tilt, orientation, and pressure data are used by the renderer, which adjusts the stroke according to the styling properties. For more details, refer to the Renderer section.

### Series of events

In some cases, you may want to send a set of strokes to the engine in a single pass, for instance if you import ink from outside of the iink
model that you want to process as a single batch.

For all types of parts but “Text Document”, iink SDK provides a method to input in a single pass a series of pointer events, pointerEvents:,
that take in parameter an array of IINKPointerEvent objects.

Here is an example:

```swift
// Build the pointer events array
let n = 23;
var eventArr:[IINKPointerEvent]=[]

// Stroke 1
eventArr.append(IINKPointerEvent(eventType: IINKPointerEventType.down,x: 184, y: 124,t: -1, f: 0, pointerType: IINKPointerType.pen , pointerId: 1))
eventArr.append(IINKPointerEvent( eventType: IINKPointerEventType.move,x: 184, y: 125,t: -1, f: 0,pointerType: IINKPointerType.pen , pointerId: 1))
eventArr.append(IINKPointerEvent(eventType: IINKPointerEventType.move,x: 184, y: 128,t: -1, f: 0, pointerType: IINKPointerType.pen , pointerId: 1))
eventArr.append(IINKPointerEvent(eventType: IINKPointerEventType.move,x: 184, y: 133,t: -1, f: 0, pointerType: IINKPointerType.pen , pointerId: 1))
eventArr.append(IINKPointerEvent(eventType: IINKPointerEventType.move,x: 184, y: 152,t: -1, f: 0,pointerType: IINKPointerType.pen , pointerId: 1 ))
eventArr.append(IINKPointerEvent(eventType: IINKPointerEventType.move,x: 184, y: 158,t: -1, f: 0,pointerType: IINKPointerType.pen , pointerId: 1 ))
eventArr.append(IINKPointerEvent(eventType: IINKPointerEventType.move,x: 184, y: 163,t: -1, f: 0,pointerType: IINKPointerType.pen , pointerId: 1 ))
eventArr.append(IINKPointerEvent(eventType: IINKPointerEventType.move,x: 183, y: 167,t: -1, f: 0,pointerType: IINKPointerType.pen , pointerId: 1 ))
eventArr.append(IINKPointerEvent(eventType: IINKPointerEventType.move,x: 183, y: 174,t: -1, f: 0,pointerType: IINKPointerType.pen , pointerId: 1 ))
eventArr.append(IINKPointerEvent(eventType: IINKPointerEventType.move,x: 183, y: 183,t: -1, f: 0, pointerType: IINKPointerType.pen , pointerId: 1))
eventArr.append(IINKPointerEvent(eventType: IINKPointerEventType.up,x: 183, y: 184,t: -1, f: 0, pointerType: IINKPointerType.pen , pointerId: 1))

// Stroke 2
eventArr.append(IINKPointerEvent(eventType: IINKPointerEventType.down, x: 150, y: 126,t: -1, f: 0,pointerType: IINKPointerType.pen , pointerId: 1 ))
eventArr.append(IINKPointerEvent(eventType: IINKPointerEventType.move, x: 151, y: 126,t: -1, f: 0,pointerType: IINKPointerType.pen , pointerId: 1 ))
eventArr.append(IINKPointerEvent(eventType: IINKPointerEventType.move, x: 152, y: 126,t: -1, f: 0, pointerType: IINKPointerType.pen , pointerId: 1))
eventArr.append(IINKPointerEvent(eventType: IINKPointerEventType.move, x: 158, y: 126,t: -1, f: 0,pointerType: IINKPointerType.pen , pointerId: 1))
eventArr.append(IINKPointerEvent(eventType: IINKPointerEventType.move, x: 166, y: 126,t: -1, f: 0,pointerType: IINKPointerType.pen , pointerId: 1))
eventArr.append(IINKPointerEvent(eventType: IINKPointerEventType.move, x: 184, y: 126,t: -1, f: 0,pointerType: IINKPointerType.pen , pointerId: 1))
eventArr.append(IINKPointerEvent(eventType: IINKPointerEventType.move, x: 190, y: 128,t: -1, f: 0,pointerType: IINKPointerType.pen , pointerId: 1))
eventArr.append(IINKPointerEvent(eventType: IINKPointerEventType.move, x: 196, y: 128,t: -1, f: 0,pointerType: IINKPointerType.pen , pointerId: 1))
eventArr.append(IINKPointerEvent(eventType: IINKPointerEventType.move, x: 200, y: 128,t: -1, f: 0,pointerType: IINKPointerType.pen , pointerId: 1))
eventArr.append(IINKPointerEvent(eventType: IINKPointerEventType.move, x: 207, y: 128,t: -1, f: 0,pointerType: IINKPointerType.pen , pointerId: 1))
eventArr.append(IINKPointerEvent(eventType: IINKPointerEventType.move, x: 208, y: 128,t: -1, f: 0,pointerType: IINKPointerType.pen , pointerId: 1))
eventArr.append(IINKPointerEvent(eventType: IINKPointerEventType.up,x: 209, y: 128,t: -1, f: 0, pointerType: IINKPointerType.pen , pointerId: 1 ))

//provide the pointer events to the editor
editor.pointerEvents(&eventArr, count: n, doProcessGestures: false)
```

When calling `pointerEvents:count:doProcessGestures:error:`to process a large quantity of strokes, you should set `doProcessGestures`to `NO`to explicitly prevent [gesture detection](#edit-and-decoration-gestures)and allow better performances. 

For the particular case of “Text Document” parts, you should:

1. Send each batch of pointer events to a dedicated “Text”, “Math”, “Diagram” or “Raw Content” part depending on the type of the content you want
to process. Remember to disable the guides on “Text” parts if you cannot ensure that they will match the baselines of the ink words.
2. Call waitForIdle() to ensure that the recognition is complete.
3. Paste as a block into your “Text Document” part at the appropriate location.

When pasting a “Text” part into a “Text Document”, iink SDK will attempt to automatically adjust the handwritten content to the
guides. 

It is possible to configure the maximum number of threads to be used by the engine for text recognition, by setting max-recognition-thread-count configuration value to the number of threads to be used (default is 1).
This tuning might be relevant when processing at one time a large series of events.

## Edit and decoration gestures

MyScript iink SDK supports all the standard gestures defined as part of Interactive Ink.

There is nothing particular to do to benefit from gestures when using the PEN tool. The SDK will take care of detecting and applying the effect of the gestures from the provided input
without any plumbing needed.

Decorations can be styled and will be taken into account when generating some of the export formats (ex: text underlining will be
ignored for a simple text export, will turn bold in the case of a docx export and be semantically tagged in a jiix export).

You can get a notification when a pen or a touch gesture is detected by attaching to the IINKEditor a delegate conforming to the IINKGestureDelegate protocol.

By default, the behaviour associated with the gesture is the same as in previous iink versions.
But you can choose the action associated to the gesture to decide what to do with its stroke:

- ADD_STROKE to add the gesture stroke as a regular stroke (if relevant) without applying the gesture behavior.
- APPLY_GESTURE to apply the gesture behavior, as configured in the editor.
- IGNORE to discard the gesture stroke without applying the gesture behavior.

In order to avoid any action conflict, only one IINKGestureDelegate can be used per editor. 

## Other edit operations

The following operations can be directly made on the content of a part via an Editor object:

- Undo/Redo :
iink operations handled by the undo/redo stack are operations that modify the model. Such operations include adding stroke, applying gestures, converting the content.

For further details or if you need to integrate iink SDK undo/redo with your own undo/redo stack, refer to [this page](../../advanced/combined-undo-redo-stacks/)(advanced) 
- Clear is applied on the whole “ContentPart”.

Most operations, however, are to be done on content blocks.

## Recognition feedback

### Display recognized text in real time

The UI Reference Implementation comes with a “smart guide” component that lets you provide real-time text recognition feedback to your end users and allows them
to select alternative interpretations from the engine.

Refer to the page describing how to work with text recognition candidates for more information.

### Improve user experience

- Sometimes, the block extraction or segmentation does not give the expected result, leading to a degraded user experience with some ink recognized as text instead of shape, or shape as drawing, etc.
In order to cope with such a situation, the lasso selector can be used to select some content, and then force
the selected content to be recognized as a specific type and/or grouped with the editor setSelectionType().
The list of possible types is provided by the getAvailableSelectionTypes() method.
- The setSelectionType() can also be used to perform math recognition on a selection of strokes of a “Raw Content” part.
In this case, make sure to activate the math recognition by adding the math in the raw-content.recognition.types and deploy the math resources in your application.

## Monitoring changes in the model

There are cases where it makes sense to be notified of what occurs in the model. For instance, you may want to update the states of the undo/redo buttons of
your interface or only permit an export when there is something to export.

You can attach a delegate conforming to the IINKEditorDelegate protocol to an IINKEditor object’: the protocol has several methods that let you know when any change occurs within the model.

IINKEditorDelegate also provides an onError: method that you can implement to be notified when anything goes wrong.
It is strongly recommended to implement it, as it allows detecting some frequently seen issues such as recognition assets or configurations
not found by the engine.

In addition, the IINKEditor class provides other useful methods/properties, such as:

- idle - Returns true/YES if any ongoing processing by the engine is over
- waitForIdle - Blocks your thread until the engine is idle. It allows waiting for recognition to be complete before exporting, converting or
manipulating the content.

`isIdle`will always be `false`/ `NO`when accessed from inside a `contentChanged:`notification. To avoid deadlocks, **do not**call `waitForIdle`, `undo`or `redo`from inside an `IINKEditorDelegate`notification. 

If you rely on the reference rendering implementation provided by MyScript, ink input will be transparently managed by the
EditorViewController.

At this stage, you have learnt to write in an application and see actual ink being rendered!

---

## Tool controller

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/ios/fundamentals/tool-controller/*

Tool controller 

This page focuses on the role of the IINKToolController object, that allows to manage multiple tools in iink SDK.

The iink v1.x API used to consider that pen events were dedicated to write or edit content (text, math or
shape content, edit gestures, etc.) and touch events to manipulate content (select, drag & drop, scroll, etc.).

The introduction of the IINKToolController object enables to associate input sources with interaction tools, such as pen, eraser, highlighter and selector. For instance, a pen input can now be used to select content with the selector (lasso) tool.

To do so, the IINKToolController links pointer types representing input mediums to intents, so that you can customize their interaction patterns.

## Pointer types and Pointer tools

### Pointer type

The point of contact can be made on the screen by several input devices.
The IINKPointerType enum defines this source of input. The possible values are:

- PEN : an active stylus.
- TOUCH : a finger on a touchscreen (or a passive stylus).
- ERASER: an eraser or inverted pen.
- MOUSE : a mouse.

In addition, we have planned some extra sources of input, in order to ease your integration of specific use cases or any new future pointer type. An example of usage would be a pen while holding a button.
The available enum values for such specific cases are: CUSTOM_1, CUSTOM_2, CUSTOM_3, CUSTOM_4, CUSTOM_5.

### Pointer tool

The intent of the event on the content is defined by the IINKPointerTool enum. The possible values are:

- PEN : corresponds to actions like writing or drawing some contents, performing ink gesture such as a scratch, or resizing a box by dragging its handle.
- HAND : aims at interacting with already selected content, for instance for moving or resizing it, converting it.
- ERASER : aims at erasing some content.
- SELECTOR : aims at selecting some content by surrounding it with a lasso, so that further actions can be applied on the selection.
The selector.shape property determines the geometrical shape drawn with the lasso selector: either a polygon (by default) or a rectangle.
In Raw Content and Diagram, you can choose with the raw-content.selection.lasso-outline and diagram.selection.lasso-outline properties whether the lasso outline is as drawn or fitted. For more details, check the configuration page.
- HIGHLIGHTER : aims at highlighting some content anywhere in a page, regardless of the type of paragraph or block or the presence of bold. It can also be used to color shapes or change text or ink color.

## Mapping Pointer types to tools

Mapping pointer types to tools is necessary so that iink knows how it should interpret the captured events.
For instance, it determines a selection by analysing the items within the lasso strokes when the PEN pointer type is linked to the SELECTOR pointer tool,
whereas it performs text and gestures recognition when the PEN pointer type is linked to the PEN tool.

### Getting a Tool Controller

The IINKEngine object lets you create the IINKToolController:

```swift
let toolController: IINKToolController = engine.createToolController()
```

By default, this IINKToolController comes with a predefined cabling between pointer types and intents:

| | PEN | HAND | ERASER |
| --- | --- | --- | --- |
| PEN | X | | |
| TOUCH | | X | |
| ERASER | | | X |
| MOUSE | X | | |
| CUSTOM | X | | |
| | | | |

### Customizing your Tool Controller

But should you want to use your input for another intent, you can customize your tool controller. All you have to do is modify the link between the input medium and the given intent.

For this purpose, you should call the IINKToolController set(tool:forType:) method. For instance, if you want to use your active pen to highlight:

```swift
toolController.set(tool: .highlighter, forType: .pen);
```

### Integration tips

If you want to add a toolbar in your application, the set(tool:forType:) method should be used when the user switches a tool mapped to the same input type: for instance from PEN to HIGHLIGHTER.
You can draw on the Demo example that implements a toolbar and illustrates how to switch tool.

In addition, this sample lets you choose whether you use an active pen mode or not: this mode relies on the principle of using the pen to write and the finger to manipulate content.

If your user has an active stylus, we strongly recommended you to keep this rule. 

The following tables sums up the mapping choices of our Demo example, that can guide you in your integration:

| Pointer Type | Pointer Tool in active pen mode | Pointer Tool with active pen disabled |
| --- | --- | --- |
| PEN | Current selected tool1 | Current selected tool2 |
| TOUCH | HAND | Current selected tool2 |
| ERASER | ERASER | ERASER |
| MOUSE | Current selected tool1 | Current selected tool2 |
| CUSTOM | None | None |
| | | |

## Styling

You can associate a style to a given tool.
The set(style:forTool:) method allows you to modify the predefined style coupled with tools that add content to the Content Part, like the PEN and HIGHLIGHTER.
This method is useful when you want to let end users choose styling parameters like the color. For instance, they may want to write in blue and highlight in yellow.

For further guidelines on how to set a style, jump to the styling page.

1. The current Pointer Tool can be PEN, ERASER, SELECTOR or HIGHLIGHTER. ↩ ↩2
2. The current Pointer Tool can be PEN, HAND,ERASER, SELECTOR or HIGHLIGHTER. ↩ ↩2 ↩3

---

## Selection and block

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/ios/fundamentals/block-selection-management/*

Selection and block 

This page depicts how selections and blocks are managed by the IINKEditor object within iink SDK.

## Selection and block objects

Selection and block contents are both subdivisions of the content part:

- A content selection is a subset of the content part that can be obtained by selecting a geometrical area within a content part thanks to the lasso selector tool.

For the moment, the lasso selection is limited to “Diagram”, “Raw Content” and “Text Document” parts 

When the captured strokes representing the lasso are sent to the editor, iink SDK analyzes what they surround to determine a selection.
This selection is represented by a IINKContentSelection object.
If you implement the Canvas setDropShadow method, your end-users will get an immediate visual feedback on the selection with a dropshadow added on the selected items.

Listening to the selectionChanged() event lets also you know that some selection changes have occurred and that
you can retrieve the corresponding selection by calling getSelection on the editor.

The editor has a set of utility methods to then retrieve information about the current selection, like the blocks included in it or intersecting with it, or the list of possible actions on it. In addition, the API lets you programmatically set a selection.

For the full list of methods and how to use them, please browse the documentation from Xcode. 
- A content block is a semantic subdivision of the content part, and may contain data and/or other blocks.
It has a unique id and a defined type (“Text”, “Math”, “Diagram”, “Raw Content”, “Container”…). For example:

A “Math” part will only contain a single block, hosting the math content itself.
A “Text Document” part will be more complex, as it can host text paragraphs, math equations, diagrams and drawings, arranged in a complex layout, sometimes
one after the other, sometimes alongside one another. This is where “Container” blocks can be used to semantically group sub-blocks together.


The following illustration shows how these different blocks relate together inside their parent parts:

Package“Text” part“Math” part“Text Document” part012get root block“Text”“Math”“Container”blocks“Math”“Text”get part“Diagram”BlockhierarchySerialization 

When diagram.enable-sub-blocks is set to true in the configuration, “Diagram” blocks contain sub blocks of type “Text”, “Node”, “Edge” or “Polyedge”
describing the content of the diagram.

In iink SDK, a content block is represented by a IINKContentBlock object that inherits from the IINKContentSelection object.

- Both content block and selection objects have a bounding box that can be retrieved with the editor getBox method.
The part they belong to is accessible with the part method.

## Operations common to blocks and selections

Some operations are possible at a finer granularity than the part, with either blocks or selections.
The following sections list those main operations:

### Retrieving possible actions

For an ease of integration, you can interrogate the editor to get the supported format/type/state related to the actions you intend to apply on the selection/block.

- For instance, to determine whether an export action is possible, you can use the supportedExportMimeTypes.
- When dealing with a lasso selection, the getAvailableSelectionModes() method lets you retrieve the selection modes of the active selection associated with the editor.
You can then choose which selection mode to apply on it with by setting the mode.
This can be useful, for instance, in the case of a lasso selection to choose between a lasso outline, item handles (in case the selection is made of a single item), or resize handles.

For further details, you can refer to the [Demo example](../get-started/#example-applications)implementation of selection and block context menus. 

### Checking a block hierarchy or a selection validity

It is important to note that a block hierarchy or a content selection is only valid at a given point in time.
For instance, in the case of a Text Document, inserting new blocks, removing some text using a gesture, are some examples of events
that may invalidate the block hierarchy or the content selection you previously retrieved.
So, to check an object validity, call its valid property. Alternatively, listening to contentChanged:blockIds: and selectionChanged events
using an IINKEditorDelegate on your IINKEditor object will provide hints that your blocks/selection may have become invalid.

### Transformation operations

The editor lets you apply geometrical transformations like scaling or translation on selected content. Not all transformations are permitted on any block or selection.
So, you can check whether a transformation is allowed with transformStatus(forTransform:selection:) before actually applying it with the transform() method.

### Other operations

- convert(selection:targetState:) lets you convert the ink inside a given block or selection.
- export(selection:mimeType:) lets you export the content of a selection or of a specific block, including its children
- copy:error: lets you copy a block/selection into the internal clipboard. You can then paste it at a given location using paste(:at),
much like you would add a new block.
Text copy and paste works from various text block sources (“Text”, “Diagram” or “Raw Content”) to either a “Text Document” or a “Text” part.
In the latter case, the part must be empty before performing the paste.
- erase:error: lets you remove the content selection or non-root block from the editor part.
- isempty:error: lets you check whether this selection/block is empty or invalid. It also returns true when the editor is not associated with a part.
- set(:textFormat:selection) lets you programmatically format the text blocks that are contained in the selection, to paragraph (P), headings of level 1 (H1) or level 2 (H2),
like you would do with an underline decoration gestures.
The corresponding CSS styling class is applied.
The supportedTextFormats(forSelection:) method allows you to retrieve the available formats.

## Block specific operations

### Navigating the block hierarchy

Any part you create contains a root block.
The different blocks form a hierarchy, which root can be obtained by calling the rootBlock property on the parent part.
Each block, in turn, has a children property that will return its own children, if any, and a parent one that will return its parent.

### Block addition

The editor offers methods for adding blocks.

- The addBlock(at:type:) method adds a new block at a given location in compatible parts,
as a way to import content (only “Text Document” parts support this feature as of now).
- A dedicated addImage(position:file:mimeType:) method allows you to insert an image as a “Drawing” block inside a “Text Document” part or as an “Image” block inside a “RawContent” part.
It is possible to activate rotation of images in Raw Content parts with the “raw-content.rotation” property.

### Placeholder block

A placeholder block is designed to provide integrators with a method to utilize the UI features of the iink SDK inside a “RawContent” part to manage content that is not inherently recognized by iink.
It is essentially an image that can be accurately positioned and linked with specific metadata.
So, this block is defined by its exact position, image, interactivity options, and custom metadata, allowing you to store relevant information within your document.

You should avoid mixing keyboard input with placeholders and converted text, as both will be edited differently 

You can use the IINKPlaceholderController object associated to the IINKEditor to add and manipulate placeholders within a “RawContent” part.
The IINKPlaceholderInteractivityOptions object specifies the capabilities for interacting with the placeholder.

### Other block operation

- hitBlock: lets you know the top-most block at a given location, if there is any.
It makes it possible for example to know which block is tapped or pressed by a user.

---

## Conversion

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/ios/fundamentals/conversion/*

Conversion 

In iink SDK terminology, “conversion” refers to the replacement of some handwritten content by a clean, typeset equivalent.

## Conversion vs. recognition

Conversion is an explicit action you can trigger to replace ink content with a typeset equivalent.
It is different from the recognition process it relies on, which runs in background and interprets any input, making it interactive.

You can convert content blocks or selections by calling the convert(selection:targetState:) method of your editor object.

## Target state

When calling convert(selection:targetState:), you are expected to provide the target state you want to reach:

- DigitalPublish - Typeset content, adapted for publication (small font size, and fitted graphics in the case of a Text Document),
- DigitalEdit - Typeset content, suitable for edition (font size that is large enough for editing, expanded graphics).

You can convert back and forth between the DigitalPublish and DigitalEdit states. 

MyScript iink SDK handles a third target conversion state: Handwriting that corresponds to handwritten content (raw ink), and is one of the possible states that can be obtained when retrieving a content selection conversion state.

You cannot revert back to the Handwriting state from the DigitalPublish and DigitalEdit states. 

## Fonts

### Selecting a font family

To convert your text content, iink SDK needs to have information about the font family you use.
The family choice relies on your styling options: by default a font family is defined for each content type that you can modify by setting a theme.
If the font family is not installed on the device on which your application is running, iink will use the device default font family.

If the font family that is actually used by the device does not support all symbols, you might get some unexpected squares or symbols displayed instead of expected glyphs. In order to improve this situation, you can consider two options:

- Either you have the possibility to install the default font family on the targeted device.
- Or you have another font family available on the device that supports more symbols than the device default font family. In this case, you can set a theme to use this font family.

The Demo example also illustrates how you can integrate your own fonts by embedding them in your application, then configuring your application to use them.
In this example, we use the MyScript Inter and STIX Two fonts that ensure a proper typeset rendering of all Latin/Cyrillic/Greek symbols recognized by MyScript iink SDK.

### Computing font metrics

In addition, iink SDK requires you to attach to your editor an object conforming to the IINKIFontMetricsProvider protocol using set(:fontMetricsProvider).

As implementing a font metrics provider is a rather touchy task, MyScript provides you via the iink SDK example repository with a
reference implementation.

If you rely on the [reference implementation](../rendering/#reference-implementation), binding an editor to the editor view
automatically attaches a font metrics provider to your editor. 

## Math specifics

When math solver is active, converting the math in a Math or Text Document part will trigger solving, if the required conditions are
in place.

---

## Zooming and scrolling

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/ios/fundamentals/zooming-and-scrolling/*

Zooming and scrolling 

This page explains how zooming and scrolling can be managed via the IINKRenderer object of iink SDK.

## View transformation matrix

Although interactive ink is digital by essence, handwriting itself has its roots in the physical world.
A user feels comfortable when writing with a certain line spacing and will write differently depending on the type and quality of its stylus.
Similarly the recognition engine will not interpret the same way an ink circle, if it is almost undistinguishable from a dot or if it one centimeter wide.
True to this anchoring in the physical world, iink SDK internally stores its data in millimeters.

Your application, however, will most likely work in view coordinates, and this is the unit you will rely on to dispatch input to the SDK.
As you may also specify a zoom factor, things are likely to get complicated.

MyScript iink SDK makes the link between these two coordinate systems via the view transform of the IINKRenderer object you attached to your
editor. It takes into account dpi, zoom and potential offset.

Like with most iink SDK APIs, you do not need to manipulate the transformation matrix yourself. You can however access it via the viewTransform property of
the renderer and use it to transform from one system into the other.

## View size

The size of the view must be provided to the editor using the viewSize property.
If not, an exception will be raised when trying to attach a part to the editor (note that in the reference implementation,
this call is made for you as part of the implementation of the EditorViewController object).

The size of the view plays an important role to enable interactive content to dynamically reflow and adjust to the view size.

## Zoom and scroll management

Zooming and scrolling are managed by acting on the view transformation matrix.
Rather than manipulating it directly, however, a set of convenience methods are provided on the renderer object.

If you change the renderer transformation matrix, you need to invalidate the render target to force a redraw. 

### Zooming

You can manipulate the absolute value of the view scale with the viewScale property. A scale of 2.0 will make your content look twice as large as it is in
reality, while a scale of 0.5 will render it twice smaller.

Alternatively, you can apply a zoom factor relatively to the current scale by calling zoom() and passing it the desired factor.

For example:

```swift
renderer.viewScale=2.0;
renderer.zoom(4.2); /* Scale = 8.0f */
```

If you are processing a pinch to zoom gesture, you may also want to specify the location of the point around which to adjust the zoom. In this case, use
zoom(at:factor:) and provide the coordinates of the point to consider in addition to the zoom factor you want to apply.

### Scrolling

To scroll the view, just apply an offset to the renderer via the viewOffset property with the x and y absolute components of the offset to consider.

For example:

```swift
renderer.viewOffset = CGPoint(x: 2.4,y: 4.2); /* Offset = (2.4, 4.2) */
renderer.viewOffset = CGPoint(x: 1.4,y: 2.4); /* Offset = (1.4, 2.4) */
```

---

## Styling

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/ios/fundamentals/styling/*

Styling 

MyScript iink SDK makes it easy to style content.
In this part of the guide, you will learn how to set a theme and how you can change the style of the pen at any time.

## How to set the style of the strokes

You can set the style associated with a pointer tool that adds content to the Content Part, for example to choose the PEN or HIGHLIGHTER color or their thicknesses.
This is useful when providing end users with a color palette or when letting them define the characteristics of the PEN or HIGHLIGHTER tool.

It consists in directly setting the style of the tool by calling set(style:forTool:) method on the tool controller.

It makes it easy to dynamically create styles (for instance if you let your users build their own color palettes) and will be saved within the content part.
Supported properties are color, -myscript-pen-brush and -myscript-pen-width.

Example applied on the pen tool:

```swift
editor?.toolController?.set(style: "color: #00FF00FF; -myscript-pen-width: 2.4", forTool: IINKPointerTool.pen)
```

### Pressure, tilt and orientation settings

There are three additional options -myscript-pen-orientation-sensitivity, -myscript-pen-tilt-sensitivity and -myscript-pen-pressure-sensitivity to adjust the effect of orientation, tilt and pressure sensitivity on stroke rendering when such information is present in the input pointer events for the Editor.

To get the best effect according to your brush, you will need to [adjust their values](../../../reference/styling/), as the effect is disabled by default and an optimized effect for each brush may require a different set of values. 

Example of style applied on a custom brush:

```json
"-myscript-pen-brush: Extra-Pencil; -myscript-pen-pressure-sensitivity: 1.0; -myscript-pen-tilt-sensitivity: 1.0; -myscript-pen-orientation-sensitivity: 1.0;"
```

## Fonts style with a theme

### Main principle

A theme is a style sheet that influences the look & feel of the content rendered by a particular IINKEditor object.
It is not specific to any particular piece of content and it is therefore not stored in the IINKContentPart.

The same content will look different if it is opened by two editor instances configured with different themes. 

The style sheet shall be passed as a string via the theme property of the IINKEditor object. For example, to set the default text fonts family for the
current editor, you can write:

```swift
editor?.set(theme: ".text { font-family: Courier New; } ")
```

MyScript iink SDK dynamically computes the default styling parameters such as line height and font size, based on the device resolution.
You can override this default styling, by setting a theme: values defined by your provided style sheet will have a higher priority.

Theme changes are not managed by iink SDK undo/redo stack. To let your users undo or redo theme changes, you have to manage it on the integration side.
For a possible implementation path, read how you can combine the iink SDK undo/redo stack with that of your application (advanced).

### Illustration by an example

Let’s imagine that you have developed an application based on Math content:

You may want converted content to appear blue, while keeping the default black color for handwritten ink.
You may also choose a nice green color for the results of the math solver, and set the font to bold (weight of 700) and italic.

The code would look like this:

```swift
editor?.set(theme: ".math {" +
" font-family: STIX Two Math;" +
" color: #3A308CFF; }" +
".math-solved {" +
" color: #1E9035FF;" +
" font-weight: 700;" +
" font-style: italic;" +
"}")
```

In this example, the values defined in the new style sheet overwrote the values of the default built-in style sheet.

Note that there is an order of precedence between the different ways to adjust the style: the tool controller properties always override the theme, which overrides the default stylesheet. 

### How to apply style a posteriori

Depending on the Content Part type, it is possible to apply style on some content after it has been written or typeset:

1. Select the content either with the lasso selector or as an entire block.
2. Call the editor applyStyle method with the corresponding selection/block and the CSS style properties to apply.

## iink SDK CSS built-in classes and properties

The full reference of supported classes and properties can be found in the styling reference.

---

## Custom inking

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/ios/advanced/custom-inking/*

Custom inking 

This page explains how to customize iink SDK stroke rendering.

## Terminology

In MyScript terminology, “inking” refers to the process of rendering ink strokes. An inking algorithm typically processes the coordinates of the points of a
stroke, their associated pressure or timestamp information, as well as stroke styling such as color or width. It consists of two main steps:

1. computation of the envelope (i.e. the geometry of the stroke),
2. drawing of the stroke itself.

While iink SDK comes with its own built-in inking, the toolkit is flexible enough to let you customize these steps.

## Use cases

If you are integrating iink SDK into an application that already implements its own inking capabilities, you may want to make sure that the same rendering
algorithm is used for both iink- and application-managed content.

MyScript iink SDK can be tuned to address the following use cases:

- You just want to influence the shape of the strokes to render and let iink SDK draw the strokes by stroking or filling the envelop you define. In this
case, all you have to do is to implement and register your own stroker.
- You additionally want to draw the strokes by yourself, for instance if you need to draw textured strokes or if you rely on a rendering technology like
OpenGL and want to use particles instead of filling an envelope. In this case, in addition to implement your own stroker (it is required
by iink SDK, as explained in the following section), you will need to store information into generated path to be able to use them to render the strokes by
yourself.

This inking customization should be considered with special care as modifying the default implementation might reduce drastically the rendering performance. 

## Requirements from iink SDK

Independently from the amount of customization you intend to apply to stroke rendering, iink SDK needs to know as precisely as possible the envelope of the
strokes you intend to draw.

An envelope corresponds to the geometrical shape of the stroke, as shown in the following illustration:

StrokeEnvelop 

Among other things, knowing the envelops of the strokes lets iink SDK optimize rendering operations (by computing areas to refresh following changes in the
model), know which items to render at a given point in time and manage the geometry of selections. A precise envelop definition is key to get good results.

## How to use the API

To define your own stroker, you should:

1. Define a custom stroker object that adopts the IINKIStroker protocol: its stroke and isFill methods respectively let you return the envelop of a given stroke as an IINKIPath instance
and choose whether iink SDK shall fill or just stroke the resulting path.
2. Define a custom stroker factory that conforms to the IINKIStrokerFactory protocol: the createStroker method will let you return an instance of your custom stroker.
3. Instantiate your custom stroker factory and register it to your IINKRenderer class with the registerStroker method (you can unregister it later using
unregisterStroker method of the IINKRenderer). This method will also let you specify the name of the brush corresponding to your stroker.
4. Use the brush name you defined to style the ink.

To render the strokes by yourself, you may need to have your own implementation of IINKIPath to store stroke information provided via the stroke method of the IINKIStroker interface.
Data stored within IINKIPath objects will then be available in IINKICanvas drawPath method for you to draw the stroke in a custom way.

A platform-specific implementation of the `IINKIPath`protocol is provided for each target platform via the [UI Reference Implementation](../../fundamentals/rendering/#reference-implementation). You may adapt or subclass it to store the stroke information. 

Note that depending on whether you close or not your paths and the value you return with isFill, you will define a different envelope. The following figure shows in black the resulting envelope depending on the options and the state of the path in red:

Rendering(fill = true)PathRendering(fill = false)w/2 

As you can see, if you choose to return false in the isFill property, iink SDK will consider a larger envelope than what is strictly returned by your path,
as it will take into account the pixel width of the stroke (width parameter of the stroke method) to stroke the path.

## Code snippets

For the sake of example, this section shows how to implement a very basic inking algorithm based on “line to” instructions. If you are interested to develop
your own inking, you will likely implement something both smarter and better looking, but the structure of the code will be similar.

### Custom stroker

Let’s start by implementing the CustomStroker class:

```objective_c
@implementation CustomStroker

- (BOOL)isFill
{
return NO;
}

- (void)stroke:(nonnull IINKPoint *)input
count:(NSInteger)count
width:(float)width
pixelSize:(float)pixelSize
output:(nonnull id<IINKIPath>)output
{
[output moveTo:CGPointMake(input[0].x, input[0].y)];

for (int i = 1; i < count; ++i)
[output lineTo:CGPointMake(input[i].x, input[i].y)];
}

@end
```

Here, the code uses the fact that a non-filled, non-closed path will be stroked by iink SDK to simplify the code. In most cases, however, you will want to
manage closed paths to create a beautiful shape for the stroke. The InkPoint structure contains all required information about the points of the stroke.

Now, let’s implement the custom stroker factory:

```objective_c
@implementation CustomStrokerFactory

- (nonnull id<IINKIStroker>)createStroker
{
return [CustomStroker alloc];
}

@end
```

All you have to do now is to instantiate your factory and register it to the renderer with an appropriate brush name:

```objective_c
self.customStrokerFactory = [CustomStrokerFactory alloc];
self.editor.renderer registerStroker:@"LineToBrush"
factory:self.customStrokerFactory
error:nil];
```

Finally, you can set the stroker in the theme of the editor:

```objective_c
self.editor.theme = @"stroke { -myscript-pen-brush: LineToBrush; }";
```

That’s it! From now on, iink SDK will rely on your custom stroker to render ink strokes!

### Custom drawing of the strokes

First, implement a custom stroker as described above to generate the paths. As explained, iink SDK requires the stroke envelopes for a variety of tasks even if you draw the strokes by yourself.

Next, create your own implementation of IINKIPath 
(you can modify or subclass the one provided by MyScript) so that you can use it to store information like point coordinates, pressure, etc. that you will need to render your stroke later. Via its internal cache, iink SDK will preserve this information for you and properly free the memory if the strokes are removed from the model.

Here is a possible implementation, based on the Path class from the UI reference implementation:

```objective_c
@interface Path ()

@end

@implementation CustomPath

- (float)getWidth{
return self.width;
}

- (void)setWidth:(float)width
{
_width = width;
}

- (void)setInkPoints:(IINKPoint *)inkPoints
{
_inkPoints = inkPoints;
}

- (IINKPoint *)getInkPoints
{
return self.inkPoints;
}

@end
```

You can now update your custom stroker implementation to store the information into the path:

```objective_c
- (void)stroke:(nonnull IINKPoint *)input
count:(NSInteger)count
width:(float)width
pixelSize:(float)pixelSize
output:(nonnull id<IINKIPath>)output
{
CustomPath *customPath = output;
[customPath setInkPoints:input];
[customPath setWidth:width];
}
```

You need to update (or subclass) the provided IINKICanvas implementation to build your custom paths:

```objective_c
- (nonnull id<IINKIPath>)createPath
{
return [[CustomPath alloc] init];
}
```

The drawPath method of IINKICanvas will now be called with our paths and you can access your stored values and draw the stroke the way you want:

```objective_c
- (void)drawPath:(id<IINKIPath>)path
{
Path *aPath = path;
CustomPath *caPath = (CustomPath*) aPath;
IINKPoint *inkPoints = caPath.inkPoints;
float width = caPath.width;

// Custom drawing
...

}
```

### Drawing of textured strokes

If you want to support textured strokes, you can register a custom stroker for each texture you support and store the necessary information for your custom
drawPath implementation to take it into account.

Ensure that the stroke is entirely drawn inside the envelope. Failure to do so will likely result in rendering issues.

---

## Result, import and export

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/ios/fundamentals/import-and-export/*

Result, import and export 

This page drives you through available possibilities to import content into iink SDK and to export content or recognition result for external usage.

MyScript iink SDK differentiates [serialization/deserialization](../storage/)(storage of the full content of the model in a fast and space
efficient manner for future reuse by the SDK) and import/export (as a way to exchange iink content with other applications). 

## Importing content

Only integrations based on rendering-driven interactivity with **Editors**currently support content import. Import is not available with **OffscreenEditors**and has no sense with **Recognizers**. 

### Import into a block

This part describes import behavior for *all cases but text data import from JIIX*, which is described [here](#text-jiix-import). 

You can import data into content blocks.
For example, the following code will import the “Hello iink SDK” text string into a “Text” part:

```swift
editor.import(mimeType: IINKMimeType.text, data: "Hello iink SDK", selection: editor.rootBlock)
```

In this case, you could have omitted to specify the block.
As the part only hosts a single root block, iink SDK can figure by itself where to import the content:

```swift
editor.import(mimeType: IINKMimeType.text, data: "Hello iink SDK", selection: nil)
```

For parts that can host multiple blocks, such as “Text Document” parts, you need to explicitly specify the target block.
If it does not exist yet, you can call addBlock(at:type:) and directly pass the data to import.

The list of supported mime types for a given block can be obtained by calling supportedImportMimeTypes(forSelection:) on the editor. For instance:

```swift
let supportedImportMimeTypes = editor.supportedImportMimeTypes(forSelection: editor.rootBlock)
```

Importing content is “destructive”: Pre-existing content will be cleared and replaced (except for [text data import from
JIIX](#text-jiix-import)). 

### Text JIIX import

When it comes to textual data, JIIX import is currently limited to text words or characters candidate changes. More import
capabilities will be provided later on.

To change the text candidates within a given Text, Raw Content or Diagram block:

1. Export the block to the JIIX format.
2. Replace the label of the target word (or character) with another word (or character) from the candidates list.
3. Import the modified JIIX data back to your block.

Importing JIIX data is only possible if the target block was not modified since it was exported. For more information, refer
to [this page](../../advanced/text-recognition-candidates/#programmatically-manage-candidates). 

### JIIX import into Diagram and Raw Content parts

When importing JIIX into “Diagram” and “Raw Content” parts, the performed action depends on the configured properties diagram.import.jiix.action and raw-content.import.jiix.action. So you should tune them according to your need:

- When the property is set to update, iink changes the text candidates as described above. This is the default action for “Diagram” parts.
- When the property is set to add or replace, iink imports the ink data: strokes, glyphs and primitives. Note that this does not reinject recognition results and iink triggers a new recognition.

The remainder of this paragraph applies to add and replace actions.
The difference between both actions, is that in the replace case, iink performs a clear, this removing all content from the part, before importing the ink data. The default action for “Raw Content” parts is add.

In order to ease the import of the ink data at a given position, you can add a “transform” key into your jiix to apply this transform on the jiix data. The json syntax is “transform”: [xx, yx, tx, xy, yy, ty]. You can see the Transform API for details on the transform components.

Only translate and positive scale are allowed in the transform for now, so xy and yx should be set to 0 and xx and yy should be > 0 

Let’s take as an example the following use case. Imagine you want to double the size of one text node into a “Diagram” part. Here is how to proceed:

- Export the “Diagram” part to the JIIX format.

```json
...
{
"type": "Text",
"parent": 183,
"id": 190,
"bounding-box": {
"x": 58.4949799,
"y": 31.677475,
"width": 10.9569321,
"height": 5.24174881
}, ...
```

- Insert the transform object with a 2 scale factor (xx and yy) into the node you want to enlarge.
The scale factor is done compared to (0,0) so don’t forget to compute the translate values (tx and ty) if you want your text to remain centered at the same location. Keeping the previous sample, the modified node would be:

```json
...
{
"type": "Text",
"parent": 183,
"id": 190,
"transform": [ 2, 0, -63.973446 , 0, 2, -34.298349],
"bounding-box": {
"x": 58.4949799,
"y": 31.677475,
"width": 10.9569321,
"height": 5.24174881
},...
```

- Import the modified JIIX data back to your part.

When applying scale to typeset nodes, keep in mind that the typeset size might be modified by iink on further convert 

### Import using a specific configuration

You can temporarily “override” the current editor configuration for the need of a specific import.
For instance, in the case of “Diagram” and “Raw Content” parts, it might be convenient to momentarily modify the current editor configuration for the need of changing the text candidates, without impacting your global or your editor configurations.
You can perform such a specific import using the method illustrated by the following example:

```swift
// Create an empty parameter set
let importParams:IINKParameterSet = engine.createParameterSet()
// Set the appropriate configuration to set import action for candidate update
importParams.set(string: "update", forKey: "raw-content.import.jiix.action")
// Import into your block the jiixString corresponding to your updated candidate
editor.import(mimeType: IINKMimeType.JIIX, data:jiixString, selection:currentBlock, overrideConfiguration: importParams)
```

### Raw ink import

To import raw ink content, instantiate an editor and pass it an array of pointer events.
Note that in this scenario, according to recognition and classification configurations, the recognition engine will automatically process the new strokes.
This approach is documented in the Editing part of this guide.

## Exporting content or getting recognition result

### Make sure that recognition is complete

Recognition can sometimes take a certain time to complete, especially if you send many strokes to the editor at once.

If you want to make sure that you export the final recognition results, you have to call waitForIdle before export() or result().

### Select what you want to export or get

Export operations with Editors are performed on content blocks or selections: For instance, this allows you to export a specific diagram from a Text Document part.
With OffscreenEditors, they are performed on a set of items and with Recognizers recognition results can only be obtained on the full context.

You can retrieve the list of supported export or result mime types by calling:

```swift
// Editor
let supportedExportMimeTypes1 = editor.supportedExportMimeTypes(forSelection: editor.rootBlock)
// OffscreenEditor
let supportedExportMimeTypes2 = offscreenEditor.supportedExportMimeTypes(myscript::iink::toStringArray(itemIds))
// Recognizer
let supportedResultMimeTypes = recognizer.supportedResultMimeTypes()
```

To export content, call the export() method of the editor or offscreenEditor object, passing it the block, selection or item ids to export and the desired mime type:

```swift
// Export a math block to MathML
let result = editor.export(selection: mathBlock, mimeType: IINKMimeType.mathML)

// Export a text document to docx
let fullPath:String = FileManager.default.pathForFileInDocumentDirectory(fileName: "document.docx")

editor.export(block: textDocBlock, toFile: fullPath , mimeType: IINKMimeType.DOCX ,imagePainter: imagePainter)
```

The API provides a convenience method that lets you omit the mime type if iink SDK is able to guess it unambiguously from the file extension:

```swift
// Export a text document to docx
let fullPath:String = FileManager.default.pathForFileInDocumentDirectory(fileName: "document.docx")
editor.export(block: editor.rootBlock, toFile: fullPath, mimeType: IINKMimeType.DOCX, imagePainter: imagePainter)
```

You can call the `IINKMimeTypeGetFileExtensions:`method defined in the `IINKMimeTypeValue`class from the `IINKMimeType.h`header file to get
the extensions supported for a given mime type. 

To get the recognition result of recognizers, call the result method of the recognizer object, passing it the desired mime type:

```swift
// Export a math recognition to LaTex
let mathResult = mathRecognizer.result(mimeType: IINKMimeType.LaTeX)

// Export a text recognition to JIIX
let textResult = textRecognizer.result(mimeType: IINKMimeType.JIIX)
```

### Image painter

Certain formats require you to provide an object conforming to the IINKImagePainter protocol to let iink SDK generate images from the content. This is
expectedly the case for png and jpeg exports, but also for formats such as docx.

A default, ready-to-use, image painter implementation is provided by MyScript as part of the UI Reference
Implementation.

If the format does not require an image painter, you can provide the export method with a null pointer instead.

To know which formats require an image painter, refer to [this page](../../../overview/import-and-export-formats/). 

### Textual vs. binary exports

Textual format exports are returned as a string that can then be programmatically manipulated.
Binary formats, on the other hand, are saved as files on the disk at a location you can specify.

```swift
let imageLoader:ImageLoader = ImageLoader()
imageLoader.editor = editor
let imagePainter:ImagePainter = ImagePainter.init(imageLoader: imageLoader)

let exportFullPath:String = FileManager.default.pathForFileInDocumentDirectory(fileName: "export.docx")

editor.export(selection: editor.rootBlock, toFile: exportFullPath , imagePainter: imagePainter)
```

You can call the IINKMimeTypeIsTextual: method defined in the IINKMimeTypeValue class of the IINKMimeType.h header file to know whether a format is
textual or binary.

### Apply a specific configuration

Some export functions let you temporarily “override” the current editor configuration for the need of a specific export. This is useful if you
want to tune the export parameters (like the type of information to export to JIIX) without impacting your global or your editor configurations.

The following example shows how you can export a block recognition result as JIIX without including original ink information:

```swift
// Create an empty parameter set
let params:IINKParameterSet = engine.createParameterSet()
// Set the appropriate configuration to exclude strokes from the export
params.set(boolean: false, forKey: "export.jiix.strokes")
// Export a block with the new configuration
let jiix = editor.export(block: editor.rootBlock, mimeType: IINKMimeType.JIIX, overrideConfiguration: params)
```

### Apply an image export configuration

Image export can apply to a part only of the page or more than the chosen block extent. You can also choose whether guides appear or not in the image. For details about the image export properties, refer to the configuration page

In order to export image, an image painter object is necessary as described in this section

The following example illustrates the export as a PNG image of a viewport. The guides are visible:

```swift
// Create an empty parameter set
let imageParams:IINKParameterSet = engine.createParameterSet()

// Set the appropriate configuration to tune the viewport to export
let originPx = Double(100)
let widthPx = Double(100)
let heightPx = Double(200)
imageParams.set(number: originPx, forKey:"export.image.viewport.x")
imageParams.set(number: originPx, forKey:"export.image.viewport.y")
imageParams.set(number: widthPx, forKey:"export.image.viewport.width")
imageParams.set(number: heightPx, forKey:"export.image.viewport.height")

// Set the appropriate configuration to enable the guides into the exported image
imageParams.set(boolean: true,forKey: "export.image.guides")

// Create the image painter
let imageLoader:ImageLoader = ImageLoader()
imageLoader.editor = editor
let imagePainter:ImagePainter = ImagePainter.init(imageLoader: imageLoader)

let fullPath:String = FileManager.default.pathForFileInDocumentDirectory(fileName: "ImageFileName.png")

// Export the image with the customised parameters
editor.export(block: editor.rootBlock,toFile: fullPath, mimeType: IINKMimeType.PNG,imagePainter: imagePainter, overrideConfiguration: imageParams)
```

## Supported imports/exports

### Exchange format

MyScript iink SDK defines its own format, called JIIX (short for JSON Interactive Ink eXchange format).

This format provides a consistent representation of the different types of content that are supported, covering semantics, positions, styling
and ink-related aspects.

Thanks to its JSON syntax, it stays readable and can be easily parsed, making it appropriate to exchange information with the host application or as a
transitory representation to support custom export formats.

The complete JIIX reference can be found [here](../../../reference/jiix/). 

### Other formats

MyScript iink SDK allows you to import and export some commonly used formats, such as LaTeX for math content or Docx in the case of Text Document blocks. The full list can be found here.

The next part of the guide will talk about zooming and scrolling.

## Useful links

- Working with content blocks
- Supported import/export formats
- JIIX format reference

---

## Text recognition candidates

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/ios/advanced/text-recognition-candidates/*

Text recognition candidates 

## Word recognition candidates

MyScript handwriting recognition tries to properly guess what a user is writing but the input may sometimes be ambiguous, like in the following example:

Should it be interpreted as “hello” or as “bella”? As a human, you would probably answer “hello”. This is also what the MyScript engine thinks in this case.
However, there is also a possibility that the writer actually meant “bella”, “hella” or even “bello”…

Internally, the recognition engine considers different hypotheses and tries to come up with the best one as the selected word candidate. It will also
return other top hypotheses, such as “bella” or “bello” as alternative word recognition candidates.

Candidates can let you assist your user to easily correct potential recognition errors or help implement a search engine that can operate on handwritten
notes with a certain level of tolerance.

You can tune the maximum number of word candidates that the recognition engine shall return by editing the recognition configuration files
and assigning SetWordListSize to the desired value.

## Programmatically manage candidates

You can also interact with candidates from your own code (this is actually how the prompter is implemented).

Let’s imagine that you get the following ink:

If you ask MyScript for a text export, it will simply return “Candidate test”, which corresponds to the best interpretation according to the engine. To access
recognition candidates, you need to ask for a JIIX export.

The result looks as follows (for the sake of the example, only the relevant parts of the JIIX export have been kept, removing all ink and bounding box
information):

```json
{
"type": "Text",
...
"label": "Candidate test",
"words": [ {
"label": "Candidate",
"candidates": [ "Candidate", "candidate", "Candidates", "candidates" ],
...
}, {
"label": " "
}, {
"label": "test",
"candidates": [ "test", "Test", "best", "tests", "Lest" ],
...
} ]
}
```

The “Candidate text” interpretation is provided by the top-level “label” key.

This top-level recognition result is split into an array of “words”, each with its own label and set of candidates (except for inter-word spaces “ “).

The “candidates” key of each word allows accessing an array of candidates, sorted from most to less likely. By default, the selected candidate, stored as the
“label”, is the first element of the list.

To select an alternative candidate, you need to:

1. Update the value of the label to one of the proposed candidates.
2. Reimport the JIIX content into the original block.

From there, iink SDK will keep your choice, except if changes in the content lead it to reconsider the recognition of this part altogether.

Important:

- Always update the label with a value corresponding to an existing candidate. This is because otherwise iink SDK may not be able to figure how to map
this interpretation to the original ink.
- To re-import content, ensure that except for the change of the “label” value you have not changed anything, either in the original block or in the JIIX
content.

## Character recognition candidates

If you work on character recognition level, rather than on word recognition level, you can apply the same recognition candidates management to characters as described above for words. The steps are the same ones with the following configuration and data:

- Include the character level information by setting the export.jiix.text.chars property to true.
- The result looks as follows (for the sake of the example, only the relevant parts of the JIIX export have been kept, removing all ink and bounding box information):

```json
"type": "Text",
...
"label": "h",
"chars": [ {
"label": "h",
"candidates": [ "h", "k", "N", "A" ],
} ]
```

To select an alternative candidate, you need to:

1. Update the value of the label to one of the proposed candidates.
2. Reimport the JIIX content into the original block.

You can tune the maximum number of character candidates that the recognition engine shall return by editing the recognition configuration files
and assigning SetCharListSize to the desired value.

---

## Error management

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/ios/fundamentals/error-management/*

Error management 

This page explains how to manage errors with iink SDK, as well as common pitfalls

## Getting error notifications

There are two ways iink SDK may return an error:

1. Via an exception during the call to an API.
2. Via the onError: method of IINKEditorDelegate, IINKOffscreenEditorDelegate or of IINKRecognizerDelegate when the error occurs in a background thread.

### Exceptions

Possible exceptions for each API call are described in detail in the corresponding API headers.

### Editor-level and OffScreenEditor-level errors

It is highly recommended that you implement the onError: method of IINKEditorDelegate or IINKOffscreenEditorDelegate as part of your integration. This callback provides detailed messages
to explain what happened.

In addition, this method comes with an error code argument that will help you customize or internationalize messages to guide your customers in their use of iink technology.

The following table lists the main errors and their possible causes.

- Configuration errors:

| Error code | Message | Possible cause/solution |
| --- | --- | --- |
| GENERIC | “error: no such configuration” | The configuration file could not be found. Check that the folder containing the *.conf file is referenced by the configuration-manager.search-path key of your engine or editor configuration. |
| GENERIC | “error: no such configuration bundle” | The configuration bundle could not be found. Check that a bundle with the provided name exists in the *.conf file specified by your engine or editor configuration. |
| GENERIC | “error: invalid configuration type”“error: failed to expand environment variables in placeholders ${}”, “error: invalid command “… | There was an error when parsing the *.conf files. Many variants of this message exist, and each of them should be self-explanatory. |

- Ink errors, when ink cannot be added to a Text Document:

| Error code | Message | Possible cause/solution |
| --- | --- | --- |
| INK_REJECTED_TOO_SMALL | “ink rejected: stroke is too small (write larger)” | The stroke you sent to the part is too small. It may originate from the use of a wrong dpi value to configure the renderer. |
| INK_REJECTED_TOO_BIG | “ink rejected: stroke is too large (write smaller)” | The stroke you sent is too large vertically: a Text Document part assumes that ink is written on, and not across, the guides. |
| INK_REJECTED_ABOVE_FIRST_LINE | “ink rejected: stroke is above first line” | Ink was written within the top margin. |
| INK_REJECTED_BEFORE_FIRST_COLUMN | “ink rejected: stroke is too far left of the first column” | Ink was written too far left. |
| INK_REJECTED_SMALL_TYPESET | “ink rejected: cannot write on DIGITAL PUBLISH paragraphs (convert to DIGITAL EDIT)” | Text blocks in DIGITAL_PUBLISH conversion state can only receive edit/decoration gestures but no input. You have to convert them to DIGITAL_EDIT to add extra content. |
| INK_REJECTED_OUT_OF_PAGE | “ink rejected: stroke is out of document bounds” | Ink was written outside of the document bounds. Note that each time content is added, iink SDK will allocate extra vertical space at the end of the page corresponding to the height of the provided view size. |
| INK_REJECTED_TOO_LONG | “ink rejected: stroke is too long” | The length of the stroke (i.e. its number of points) exceeds what the engine can process. |

- Gesture errors, when an ink gesture has been detected into a Text Document, but cannot be applied:

| Error code | Message | Possible cause/solution |
| --- | --- | --- |
| GESTURE_NOTIFICATION_NO_WORDS_TO_JOIN | “gesture: no words to join” | A join words gesture has been detected but no words to join have been found. |
| GESTURE_NOTIFICATION_MESSAGE_CANNOT_MOVE_ABOVE_FIRSTLINE | “gesture: there is no line above to join” | A join line gesture has been detected on the first line so no there is no line above to join. |
| GESTURE_NOTIFICATION_MESSAGE_UNABLE_TO_APPLY | “gesture: gesture cannot be applied” | A gesture has been detected but an unexpected error has been encountered |

- Other errors :

| Error | Message | Possible cause/solution |
| --- | --- | --- |
| Import Error | “could not import JIIX: transform contains a skew or a rotation component” | You imported a JIIX with a transform containing a skew or a rotation component but only scale and translate are now allowed. |
| Too many strokes to process | “LIMIT_EXCEEDED” | You sent more strokes to the recognition engine than what it can concurrently process. |
| Unexpected error | “INVALID_STATE” or “INTERNAL_ERROR” | The recognition engine encountered an unexpected error. |

### Recognizer-level errors

It is highly recommended that you implement the onError: method of IINKRecognizerDelegate as part of your integration. This callback provides detailed messages
to explain what happened.

In addition, this method comes with an error code argument that will help you customize or internationalize messages to guide your customers in their use of iink technology.

The following table lists the main errors and their possible causes.

- Configuration errors:

| Error code | Message | Possible cause/solution |
| --- | --- | --- |
| GENERIC | “error: no such configuration” | The configuration file could not be found. Check that the folder containing the *.conf file is referenced by the recognizer.configuration-manager.search-path key of your engine. |
| GENERIC | “error: no such configuration bundle” | The configuration bundle could not be found. Check that a bundle with the provided name exists in the *.conf file specified by your engine. |
| GENERIC | “error: invalid configuration type”“error: failed to expand environment variables in placeholders ${}”, “error: invalid command “… | There was an error when parsing the *.conf files. Many variants of this message exist, and each of them should be self-explanatory. |

- Other errors :

| Too many strokes to process | “LIMIT_EXCEEDED” | You sent more strokes to the recognition engine than what it can concurrently process. |
| --- | --- | --- |
| Unexpected error | “INVALID_STATE” or “INTERNAL_ERROR” | The recognition engine encountered an unexpected error. |

### Engine-level error

| Error | Message | Possible causes/solutions |
| --- | --- | --- |
| Package cannot be opened | “error: package is already opened” | Before closing a contentPackage, you shall ensure the editor is in idle state. |

### Certificate errors

It usually takes the form of an INVALID_CERTIFICATE message printed to the console.

If this occurs, please check:

1. That the certificate is not time-limited or still valid
2. If you retrieved the certificate from the Developer Portal, check that it was generated for the bundle ID of your application.

### No recognition

If recognition is not working, you may usually get the root cause by looking at errors raised by the editor or by the recognizer:

The following causes are the most likely to be involved:

- The configuration was not found - Ensure that the *.conf file you reference is part of the paths provided to the engine/editor/recognizer and that
the name of the bundle is correct.
- Recognition assets could not be found - Ensure that the recognition assets are properly deployed alongside your application and properly
referenced by the *.conf file.

### Recognition quality is poor

Here is a small checklist to consider in this case:

1. Did you specify the right language? - Check your engine, editor or recognizer configuration and the corresponding *.conf file and the selected bundle.
2. If you are recognizing text, are guides enabled? - If they are but you are not relying on them, they may negatively impact the recognition.
3. Did you call waitForIdle before attempting to retrieve the results? - Temporary results may not be as relevant as the final one.
4. Did you provide proper dpi value when instantiating the renderer? - This is fundamental to provide the engine with a sense of “scale”, which may let it for instance differentiate a circle, a letter “o” or a dot, if context is lacking.
5. Do you send the right content? - If not, you are not likely to get the expected output 😉!

---

## Recognition resources

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/ios/advanced/custom-recognition/*

Recognition resources 

MyScript’s recognition technology is very flexible. While the default configurations support common use cases,
this page explains how you can fine tune them to address specific needs.

## What are recognition resources?

Resources are pieces of knowledge that should be attached to the recognition engine to make it able to recognize a given language or content.

### Alphabet knowledge

An Alphabet knowledge (AK) is a resource that enables the engine to recognize individual characters for a given language and a given writing style.
Default configurations include a cursive AK for each supported language.

You can only attach a single AK to an engine at a time. 

### Linguistic knowledge

A Linguistic knowledge (LK) is a resource that provides the engine with linguistic information for a given language.
It allows the recognition engine to improve its accuracy by favoring words from its lexicon that are the most likely to occur.
Default configurations include an LK for each supported language.

Default configurations for all languages but English variants also attach a “secondary English” LK that allows the engine to recognize a mix of
the target language and English. Except for this particular case, it is not expected to mix languages together. 

### Lexicon

A lexicon is a resource that lists words that can be recognized in addition to what is included into linguistic knowledge resources.

### Subset knowledge

A subset knowledge (SK) is a resource that restricts the number of text characters or math symbols and rules that the engine shall attempt to recognize.
It thus corresponds to a restriction of another resource.

### Math grammar

A math grammar is a resource that restricts the number of math symbols and rules that the engine shall be able to process.

## Ready-to use resources delivered by MyScript

For on-device use, we deliver two different sets of ready to use recognition resources with associated configurations: the standard ones and the lite ones.

### Choosing between standard and lite resources

The standard resources should meet most of your recognition needs.
But there might be specific situation where the resource file sizes matter: as they add to the overall footprint of the OS, it reduces the space available for user data.
On low end devices, you might also need the recognition process to be faster and/or to use less CPU/battery.

The usage of lite recognition resources could tackle these needs: In addition to their lower sizes, they enable an increase in recognition speed.
But you have to be aware that using them might slightly decrease the recognition accuracy.

So, the decision to use lite versus standard resources is an arbitration between speed/sparing CPU/battery versus accuracy.

### Choosing between classical handwriting and other handwriting

- The classical (print or cursive) handwriting is the most common one. In the .conf files, its resources are defined by the text configuration Name, for instance:

```plaintext
Name: text
Type: Text
Configuration-Script:
AddResource en_US/en_US-ak-cur.res
AddResource en_US/en_US-lk-text.res
...
```

For more details to understand the .conf content, you can learn about [its syntax](#syntax). 
- In specific use cases, you may want to recognize letters, words or parts of words written over each other, without any explicit separation between consecutive fragments. This is what we call superimposed handwriting.

Superimposed recognition is not suited for use with an Editor or an OffscreenEditor 

In the .conf files, superimposed resources are defined by the text-superimposed configuration Name, for instance:

```plaintext
Name: text-superimposed
Type: Text
Configuration-Script:
AddResource en_US/en_US-ak-superimposed.res
AddResource en_US/en_US-lk-text.res
...
```

- With Japanese language, you may want to recognize vertical handwriting.

Vertical Japanese recognition is not suited for interactive use with an Editor or an OffscreenEditor. 

In the .conf files, vertical Japanese resources are defined by the vertical configuration Name:

```plaintext
Name: vertical
Type: Text
Configuration-Script:
AddResource ja_JP/ja_JP-ak-vertical.res
AddResource ja_JP/ja_JP-lk-text.res
...
```

### Downloading the resources

MyScript Developer Portal lets you download recognition assets to support a wide range of languages, as well as math, raw-content, shapes and diagram use cases.
Each pack comes with the two ready-to-use standard and lite configurations that will work in most cases.

### Procedure to use these resources:

The procedure to configure the resources is the same for the Engine or for the Text Recognizer, except that for the latter one, the configuration keys listed below must have the `recognizer.`prefix 

Step 1 Download as described above, your language pack(s), and if needed the content type package as well: math, diagram.
For raw content, refer to this table.

Step 2 Install the pack(s) in your application project:

The packs consist in a *.zip archive containing the following folders to be extracted in your project path:

- a conf folder (recognition-assets/conf) containing the standard resources configuration (*.conf),
- a conf-lite folder (recognition-assets/conf-lite) containing the lite resources configuration (*.conf),
- a * resources folder and its subtree containing the resources files (*.res).

Make sure to properly deploy these files as the .conf file refers to the .res files with relative paths. So take care to keep the archive folder structure when extracting the files 

Step 3 Modifiy the engine or recognizer configuration manager path in your application code:

Set the value of the configuration-manager.search-path and/or recognizer.configuration-manager.search-path keys to the folder(s) containing your configuration file(s) (*.conf):

- So to use the standard resources, set the value to the conf folder, for instance: zip://${packageCodePath}!/assets/conf
- Or to use the lite ones, set the value to to the conf-lite folder, for instance:zip://${packageCodePath}!/assets/conf-lite

Additionnal optional step if you want to perform superimposed recognition or vertical Japanese (only for Text Recognizer):

Modify the Text Recognizer recognizer.text.configuration.name value to text-superimposed or vertical.
For vertical Japanese, you must also disable the text guides.

Before going to production in order to avoid embedding useless resources, you should check that your assets folder contains only the necessary .res files, i.e. the ones listed in the .conf files (either in the `conf`or the `conf-lite`folder) that you are actually using. 

## Using customized resources

### Why customize the recognition?

There are a few situations where you may want to adapt these provided configurations:

- You need the engine to recognize some vocabulary that is not included within the default MyScript lexicons, like proper names.
In this case, you may build and attach a custom lexicon.
- You target different education levels with a math application and want to restrict the amount of symbols that MyScript can recognize:
this will reduce some possible ambiguities (many math symbols are very similar) and improve the overall user experience.
In that case, you can build and attach a custom math grammar, if you use an editor with legacy math recognition engine, or a custom math sk, if you use a math recognizer or an editor with latest math recognition engine.
- You are building a form application and want to reduce some fields to only accept certain types of symbols, such as alphanumerical symbols,
digits or even capital letters. In this case, consider building and attaching a subset knowledge.
- You need more or less recognition candidates to be made available to the end user, or you plan to index the recognition results for search purposes and want
to just consider the top n candidates. You may edit the configuration accordingly.

### How to do so?

An LK is not mandatory but not attaching one often results in a significant accuracy drop.
It may be relevant to build your own LK if you do not expect to write full meaningful words, for instance if you plan to filter a list with a few letters.

You can build and attach your own custom lexicons.

A customized SK can be useful in a form application, for example, to restrict the authorized characters of an email field to alphanumerical characters,
@ and a few allowed punctuation signs.

You can build and attach your own custom subset knowledge.

In education use cases, it can be useful to adapt the recognition to a given math level (for instance, only digits and basic operators for pupils):

- You can build and attach your own custom math grammars for math legacy use.
- You can build and attach your own custom math sk for math recognizer use.

## Configuration files

### Role

As explained in the runtime part of the guide, iink SDK consumes configuration files, a standardized way to provide the right
parameters and knowledge to recognize a specific type of content.

### Deployment and usage

The resources packs that we deliver contain the corresponding configuration files that can be used as explained in previous section.
This section focuses on the configuration files usage for customized resources.

To deploy and use a configuration, you need to:

1. Deploy the *.conf file with your application, along with all the resource files that it references (make sure that all paths are correct).
2. Add the folder containing the *.conf file to the paths stored in the engine configuration for the configuration-manager.search-path key.
3. Depending on the content type, set the right configuration keys. For instance, to recognize text (in “Raw Content”, “Text”, “Diagram” and “Text Document” parts)
you will need to ensure that the values of the text.configuration.bundle and text.configuration.name keys are matching your text configuration bundle and
configuration item name (see example below).

### Syntax

A configuration file is a text file with a *.conf extension. It is composed of a header (identifying a configuration bundle) and one or more named
configuration items (defining configuration names) separated by empty lines.

Here is an example:

```plaintext
# Bundle header
Bundle-Version: 2.4
Bundle-Name: en_US
Configuration-Script:
AddResDir ../resources/

# Configuration item #1
Name: text
Type: Text
Configuration-Script:
AddResource en_US/en_US-ak-cur.res
AddResource en_US/en_US-lk-text.res
SetTextListSize 1
SetWordListSize 5
SetCharListSize 1

# Configuration item #2
Name: text-no-candidate
Type: Text
Configuration-Script:
AddResource en_US/en_US-ak-cur.res
AddResource en_US/en_US-lk-text.res
SetTextListSize 1
SetWordListSize 1
SetCharListSize 1
```

Explanations:

- Lines starting with # and ! are considered as comments and ignored.
- Lines starting with a space are continuation lines. Here, several commands are gathered under Configuration-Script.
- The value provided as Bundle-name is the name of the bundle. This is what iink SDK expects as a possible value for the text.configuration.bundle
configuration key. In this example, it would be en_US.
- The value provided as Name defines a configuration item. This is one of these names that iink SDK expects as a possible value for the
text.configuration.name configuration key. In this example, it could be text and text-no-candidate. A given engine can only be
configured with a single configuration item for each type of recognizer at any point in time.
- Possible values for the Type key are: Text, Math, Shape and Analyzer. They correspond to the types of content that the core
MyScript technology is able to recognize.

It is mandatory to separate configuration items with a blank line. 

### Configuration commands

The table below lists some possible configuration commands (to be placed under Configuration-Script):

| Configuration item type | Syntax | Argument |
| --- | --- | --- |
| All | AddResDir DIRECTORY | Folder that the engine shall consider for resource files relative paths |
| | AddResource FILE | Name of an individual resource file to attach |
| Text | SetCharListSize N | An integer between 1 and 20, representing the number of character candidates to keep |
| | SetWordListSize N | An integer between 1 and 20, representing the number of word candidates to keep |
| | SetTextListSize N | An integer between 1 and 20, representing the number of text candidates to keep |

### Required bundle according to content types

The following tables lists the types of configuration items that you need to provide for iink SDK to support its different content types:

| Content type | Required configuration item types |
| --- | --- |
| Text | Text |
| Math | Math |
| Diagram | Text + Shape + Analyzer |
| Text Document | Text + Math + Shape + Analyzer |

### Required bundles for Raw Content

- If you are using a Raw Content Recognizer, refer to the Recognizers page to get the list of needed bundles.
- If you are using an Editor or OffscreenEditor, you need to deploy the following resources depending on your recognition configuration and analyzer bundle.

➤ With the latest analyzer:

| Configuration item types | Required configuration bundles | Resource package containing the bundle |
| --- | --- | --- |
| Text | ${lang} 1 | Language package defined by your lang configuration. See principles of language resources |
| Shape | shape 2 | myscript-iink-recognition-diagram.zip |
| Math | math2 3 | myscript-iink-recognition-math2.zip |
| Analyzer | raw-content2 | myscript-iink-recognition-raw-content2.zip |

➤ With the legacy analyzer:

| Configuration item types | Required configuration bundles | Resource package |
| --- | --- | --- |
| Text | ${lang} 1 | Language package defined by your lang configuration. See principles of language resources |
| Shape | shape 2 | myscript-iink-recognition-diagram.zip |
| Math | math 3 | myscript-iink-recognition-math.zip |
| Analyzer | raw-content | myscript-iink-recognition-raw-content.zip |

1. If you enable text recognition (see configuration). ↩ ↩2
2. If you enable shape recognition (see configuration). ↩ ↩2
3. If you enable math recognition (see configuration). ↩ ↩2

## Attaching resources

Resouces are attached in the Configuration-Script part of the configuration items by using the AddResource command.

For example, in the case of an en_US AK, you would write:

```plaintext
AddResource en_US/en_US-ak-cur.res
```

Make sure that the path to the resource is correct.

---

## Handwriting generation

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/ios/advanced/handwriting-generation/*

Handwriting generation 

With iink SDK 4.2, it is possible to generate handwriting for English text or for Chinese text (GB2312 character set).

## Handwriting generation main principle

Handwriting generation is the process of converting digital text to digital ink by creating the basic strokes that form the letters, words, and sentences of the input text. This feature is supported by these main objects:

- a HandwritingProfileBuilder to create a HandwritingProfile that describes the handwriting style.
- a HandwritingGenerator to generate a list of PointerEvent corresponding to the strokes from a text input String and a HandwritingProfile.
- a resource file depending on the language text you want to generate: en-hw-gen.res for English text or zh-hw-gen.res for Chinese text (GB2312 character set).

When using the `zh-hw-gen.res`, it is possible to input a mix of Chinese and English text. 

## HandwritingGenerator setup

To use the handwriting generation, you must [contact our sales team](../../../../../../contact). 
- Deploy the handwriting generation resource file corresponding to your language text in your application. The .res files are contained in the myscript-iink-handwriting-generation.zip package.
- Configure an Engine object to use this resource:

```java
Configuration conf = engine.getConfiguration();
// Set the value of the configuration-manager.search-path key to the folder(s) containing your resource.
String hwResDir = "zip://" + getPackageCodePath() + "!/assets/resources/handwriting_generation";
conf.setStringArray("configuration-manager.search-path", new String[]{hwResDir});
// Choose the handwriting generation resource: `en-hw-gen.res` or `zh-hw-gen.res`
conf.setString("handwriting-generation.init.resource","en-hw-gen.res");
```

- Create your HandwritingGenerator object:

```java
HandwritingGenerator generator = engine.createHandwritingGenerator();
```

## HandwritingProfile creation

Before using your HandwritingGenerator, you must create a HandwritingProfile, which can be either a predefined handwriting style
selected from a dataset of handwriting styles or the user’s handwriting style, which is learned from user’s handwriting samples.

### Predefined handwriting profile

The iink SDK comes with a set of predefined handwriting styles that can be retrieved by their ids.

```java
HandwritingProfileBuilder builder = generator.createHandwritingProfileBuilder();

// get the number of predefined handwriting styles for current resource
int numberOfPredefinedProfiles=builder.getPredefinedProfileCount()

// retrieve the 1st one
HandwritingProfile profile = builder.getPredefinedProfileAt(0);
```

The list of predefined handwriting styles depends on the handwriting generation resource.
So, the getPredefinedProfileCount requires the resource to be loaded, otherwise, it will load it synchronously.

To avoid the extra cost of loading when getting the number of predefined profiles, you can preload the resource using **HandwritingGenerator****loadResource**. 

### User’s handwriting style

The HandwritingProfileBuilder can also learn the user’s handwriting style from the user’s text strokes that it has recognized in the past with an Editor or an OffscreenEditor.

- It can rely either on the ContentSelection of an Editor, either a whole block or a lasso selection:

```java
// get a selection from an Editor, for instance your Root block assuming it contains recognized Text blocks
ContentBlock root = editor.getRootBlock();
// generate a profile from a content selection
HandwritingProfile profile = builder.createFromSelection(root);
```

- Or use the ContentPackage file of an Editor or an OffscreenEditor, that contains recognized text:

```java
HandwritingProfile profile = builder.createFromFile("recognized-text.iink");
```

- You can use the store method to save the generated profile to a file and easily use it again with the load method.

## Handwriting generation example

Once you have your HandwritingProfile, you are ready to generate the handwriting:

```java
// starts the handwriting generation process in a background thread with the start method
generator.start("Text", profile, null);

// requests generation, which will be performed in a background thread
generator.add("First words", MimeType.TEXT);
generator.add("More words", MimeType.TEXT);

// indicates that no more generation requests will be done
generator.end();

// waits until all generation requests are processed
generator.waitForIdle();

// get the generation results
HandwritingResult result = generator.getResult();
```

If you enter an unexpected code point, a question mark `?`will replace it. 

## Customizing handwriting generation parameters

You can provide a ParameterSet to the HandwritingGenerator to customize the handwriting generation configuration.
It allows you to tune parameter such as strokes location or size, as illustrated by this example:

```java
// Create an empty parameter set
ParameterSet generationParams = engine.createParameterSet();

// Example of custom configuration
generationParams.setNumber("handwriting-generation.session.width-mm", widthMM.x - offsetMM.x);
generationParams.setNumber("handwriting-generation.session.left-x-mm", offsetMM.x);
generationParams.setNumber("handwriting-generation.session.origin-x-mm", offsetFirstLineMM.x);
generationParams.setNumber("handwriting-generation.session.origin-y-mm", offsetMM.y);
generationParams.setNumber("handwriting-generation.session.line-gap-mm", textSize * LINE_GAP_RATIO);
generationParams.setNumber("handwriting-generation.session.x-height-mm", textSize);

// starts the handwriting generation with this custom configuration ParameterSet
generator.start("Text", profile, generationParams);
```

This section of the configuration guide describes the main handwriting generation configuration parameters.

## Handwriting generation feedback

We strongly recommend that you implement the IHandwritingGeneratorListener interface and register it with the HandwritingGenerator, as it is useful that your application is informed about both situations:

- onError when an error occurs.
- onUnsupportedCharacter when HandwritingGenerator is requested to generate an unsupported character.

The listener also implements onPartialResult for each call to HandwritingGenerator add method, when generation results are available from the HandwritingGenerator, and onEnd when generation is over.

## Handwriting result

The HandwritingResult contains the result of the handwriting generation as a list of PointerEvent with the stroke points coordinates expressed in millimeters.

To retrieve the PointerEvents, you can provide a view transform so that the stroke coordinates in millimeters are converted to view coordinates in pixels, making them directly usable with an Editor.

```java
// retrieve your Editor view transform ( pixels -> mm coordinates changes)
Transform transform = editor.getRenderer().getViewTransform();

// invert the transform ( mm -> pixels coordinates changes)
transform.invert();

// get the handwriting generation pointer events result with this transform to have the coordinates in pixels
PointerEvents resultEventsInPixels= result.toPointerEvents(transform);

// resultEventsInPixels are ready to use with your Editor
```

---

## Configuration

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/reference/configuration/*

Configuration 

MyScript iink SDK is a flexible toolkit, and its default configuration can be adjusted to meet different needs.
This page lists available options, their default values and usage.

On native platforms, you can access the `Configuration`via your `Engine`object.
Refer to the Interactive Ink runtime page of the guide for more instructions. 

Further options are available to customize your styling with css properties. They are inventoried in the styling page.

In the tables below, note how the ${KEY_NAME} syntax allows retrieving the value of another key.

## General

| Key | Type | Default value | Description |
| --- | --- | --- | --- |
| configuration-manager.search-path | string array | <empty> | List of directories where the configuration files (*.conf) used by the Editor and OffScreenEditor are stored. |
| lang | string | en_US | Defines the language used in the Editor and OffScreenEditor. |
| content-package.temp-folder | string | <empty> | Location for the temporary folder where content packages shall be extracted1. If empty, the folder will be placed alongside the corresponding content package. |
| convert.convert-on-double-tap | boolean | true | If true, double tap on a block will convert it. |
| debug.log-file | string | <empty> | Path to the file where debug logs shall be stored. |
| export.graphml.flavor | string | yed | Defines the flavor you want for GraphML export: possible values are standard and yed. The latter is recommended if you want to edit exported GraphML into yEd. The yEd flavor is also more expressive and thus truthful. |
| export.image-max-size | number | 4096 | Maximum width and height of exported images. |
| export.image-resolution | number | 300 | Resolution of the images that are exported, in dpi. |
| export.image.guides | boolean | false | If true, guides are visible in the exported images. |
| export.image.viewport.x | number | none | The x-coordinate, in pixels, of the viewport origin to be used for the image export. |
| export.image.viewport.y | number | none | The y-coordinate, in pixels, of the viewport origin to be used for the image export. |
| export.image.viewport.width | number | none | The width, in pixels, of the viewport to be used for the image export. |
| export.image.viewport.height | number | none | The height, in pixels, of the viewport to be used for the image export. |
| export.jiix.bounding-box | boolean | true | If true, JIIX export will contain the bounding boxes of exported items. |
| export.jiix.strokes | boolean | true | If true, JIIX export will include the detailed ink information. |
| export.jiix.glyphs | boolean | true | If true, JIIX export will include the converted glyphs. |
| export.jiix.primitives | boolean | true | If true, JIIX export will include the converted shape primitives. |
| export.jiix.style | boolean | false | If true, JIIX export will include the style information. Note only dynamic style will be exported, not the editor-level stylesheet. |
| export.jiix.math-label | boolean | true | If true, JIIX export will include the LaTeX label for Math blocks. |
| export.jiix.ids | boolean | false | If true, JIIX export will include item ids: is useful to get items id, without having all item information: for instance having strokes ids without their full coordinates to avoid an heavy .jiix file. |
| export.jiix.ranges | boolean | false | If true, JIIX export will include ink ranges of every object 2: is useful for having strokes ranges without their full coordinates to avoid an heavy .jiix file. |
| export.jiix.text.chars | boolean | false | If true, JIIX export will include the detailed characters information. |
| export.jiix.text.words | boolean | true | If true, JIIX export will include the detailed words information. |
| export.jiix.text.lines | boolean | false | If true, JIIX export will include the detailed geometric information per line in the text interpretation. |
| export.jiix.text.spans | boolean | false | If true, JIIX export will include detailed recognition information per line in the text interpretation 3. |
| export.jiix.deprecated.text.linebreaks | boolean | false | If true, JIIX export will include detailed information about the line breaks within a text. Deprecated, you should rather use the export.jiix.text.structure option. |
| export.jiix.text.structure | boolean | false | If true, JIIX export will include detailed information about the text layout structure for Text blocks. |
| export.jiix.shape.candidates | boolean | true | If true, JIIX export will include shape candidates when using a Shape Recognizer or a Raw Content Recognizer with shape recognition. |
| export.mathml.flavor | string | standard | Defines the flavor you want for MathML export: possible values are standard and ms-office. The latter is recommended if you want to use exported MathML into Microsoft Office suite. |
| export.temporary-file | string | <empty> | Path to temporary export file. If not set, temporary file will be created alongside the corresponding content package. |
| gesture.enable | boolean | true | If true, MyScript iink SDK will attempt to detect gestures while writing. |
| renderer.debug.draw-image-boxes | boolean | false | If true, the bounding of the images are visible. |
| renderer.debug.draw-text-boxes | boolean | false | If true, the bounding of the words (for text) or characters (for math) are visible. |
| renderer.prediction.enable | boolean | false | If true, enables the ink prediction. See rendering. mechanism. |
| renderer.prediction.duration | number | 16 | When ink prediction is enabled, defines the targeted prediction duration in milliseconds. Default value is 16, max is 200. See rendering. |
| renderer.sqrt.bar-scale | number | 1 | Adjusts the thickness of the square root bar. |
| selector.shape | string | polygon | Defines the shape of the lasso selector: possible value are polygon and rectangle. |
| max-recognition-thread-count | number | 1 | A number between 1 and 64. Maximum number of threads used by the Engine for recognition. This tuning might be relevant when processing at one time with an Editor, an OffscreenEditor or a Recognizer a large set of strokes of text, or with a Math Recognizer a large set of strokes. It is advised however, to leave this configuration to 1 if you are doing incremental recognition, as it may have a negative impact on performances and accuracy. |

## Text

| Key | Type | Default value | Description |
| --- | --- | --- | --- |
| text.configuration.bundle | string | ${lang} | Configuration bundle to be used (name of the *.conf file). |
| text.configuration.name | string | text | Configuration name, within the bundle (configuration within the *.conf file). |
| text.eraser.radius | number | 3 | Radius of the eraser tool in mm. |
| text.eraser.show | boolean | false | If true, a halo shows up at eraser position. |
| text.eraser.erase-precisely | boolean | false | If false, the eraser removes any character it touches, else it only erases ink portions within its trajectory. |
| text.eraser.dynamic-radius | boolean | false | If false, the eraser is fixed, its value is the radius. If true, the eraser size is dynamic and grows with the speed. |
| text.margin.left | number | 15 | Margin from the left of the part to the left of the text bounding box (used for reflow). |
| text.margin.right | number | 15 | Margin from the right of the part to the right of the text bounding box (used for reflow). |
| text.margin.top | number | 10 | Margin from the top of the part to the top of the text bounding box (used for reflow). |
| text.guides.enable | boolean | true | If true, guides are visible and used for convert and reflow operations. The default line spacing is 10 mm and can be tuned by choosing the .text class font-size and line-height values. |

All these `text.*`parameters only affect the “Text” content type, not “Text Document”. 

## Math

## Math general settings

| Key | Type | Default value | Description |
| --- | --- | --- | --- |
| math.configuration.bundle | string | math | Configuration bundle to be used (name of the *.conf file). |
| math.configuration.name | string | standard | Configuration name, within the bundle (configuration within the *.conf file). |
| math.convert.animate | boolean | false | If true, math animation (morphing) is performed when converting math strokes to typeset. Math animation is supported only in a Math part or Text Document part. |
| math.eraser.radius | number | 3 | Radius of the eraser tool in mm. |
| math.eraser.show | boolean | false | If true, a halo shows up at eraser position. |
| math.eraser.erase-precisely | boolean | false | If false, the eraser removes any symbol it touches, else it only erases ink portions within its trajectory. |
| math.eraser.dynamic-radius | boolean | false | If false, the eraser is fixed, its value is the radius. If true, the eraser size is dynamic and grows with the speed. |
| math.margin.bottom | number | 10 | Margin from the bottom of the part to the bottom of the math expression bounding box (used for conversion operations). |
| math.margin.left | number | 15 | Margin from the left of the part to the left of the math expression bounding box (used for conversion operations). |
| math.margin.right | number | 15 | Margin from the right of the part to the right of the math expression bounding box (used for conversion operations). |
| math.margin.top | number | 10 | Margin from the top of the part to the top of the math expression bounding box (used for conversion operations). |

## Math solver settings

| Key | Type | Default value | Description |
| --- | --- | --- | --- |
| math.solver.angle-unit | string | deg | Unit of the angle computation in the solver: It must be either deg (degrees) or rad (radians). |
| math.solver.decimal-separator | string | . | The decimal separator symbol (usually . or ,). |
| math.solver.enable | boolean | true | If true, solver result is visible upon conversion in a Math part or Text Document part. |
| math.solver.fractional-part-digits | number | 3 | The number of decimals in the solver computation result. |
| math.solver.number-format | string | decimal | The way the solver displays the results: decimal (e.g. “2.4”), rational (e.g. “3/2”) or mixed (e.g. “1½”). |
| math.solver.options | string | algebraic | numeric choice lets the solver modify the structure of the expression to obtain something computable. algebraic one preserves the structure of the input in any case. |
| math.solver.rounding-mode | string | half-up | Rounding method used to display solver results: It must be either half-up or truncate. |

| math.solver.numerical-computation | string array | [ "anywhere" ] for Editor, [ "at-right-of-equal-sign" ] for OffscreenEditor | Indicates when solver should perform a numerical-computation action. Possible values are: at-right-of-equal-sign to insert the value of left expression at the right of an equal sign without right expression, at-question-mark to replace a written question mark by the corresponding value if it can be computed. When anywhere value is set the solver performs all supported numerical computations, including the two previous cases. |
| --- | --- | --- | --- |
| math.solver.enable-syntactic-correction | boolean | true for Editor, false for OffscreenEditor | If true, the solver inserts missing fences, operands and zeros in the math formula when applying a numerical-computation action. |
| math.solver.display-implicit-multiply | boolean | true for Editor, false for OffscreenEditor | If true, the solver inserts implicit multiply operators in the math formula when applying a numerical-computation action. |
| math.solver.display-vop-implicits | boolean | false | If true, the solver inserts implicit addition operators in vertical operation when applying a numerical-computation action. |
| math.solver.auto-variable-management.enable | boolean | false | If true, enables the automatic management of variables. |
| math.solver.auto-variable-management.scoping-policy | string | closest | The scoping policy determines which variable definitions apply to a formula, identified by its block Id, when variables are used across formulas. Possible values are: closest the definition from the closest block in spatial distance is used, last-modified the most recently modified block is used, last-edited, similar to last-modified, but moving a block does not count as a modification. |
| math.solver.evaluate-resample-max-depth | number | 5 | The maximum number of resampling points that can be inserted between the equidistant points, to improve accuracy around local extrema and discontinuities when evaluating variables in a math block. 0 means no resampling. |

## Diagram

| Key | Type | Default value | Description | |
| --- | --- | --- | --- | --- |
| diagram.configuration.analyzer.bundle | string | diagram | Configuration bundle to be used (name of the *.conf file). | |
| diagram.configuration.analyzer.name | string | analyzer | Configuration name, within the bundle (configuration within the *.conf file). | |
| diagram.configuration.shape.bundle | string | diagram | Configuration bundle to be used (name of the *.conf file). | |
| diagram.configuration.shape.name | string | shape | Configuration name, within the bundle (configuration within the *.conf file). | |
| diagram.configuration.text.bundle | string | ${lang} | Configuration bundle to be used (name of the *.conf file). | |
| diagram.configuration.text.name | string | text | Configuration name, within the bundle (configuration within the *.conf file). | |
| diagram.convert.types | string array | [ "text", "shape" ] | Defines which types of blocks respond to convert operations. Blocks whose types are not listed here remain unaffected by convert operations. Possible values are text and shape. | |
| diagram.convert.snap | boolean | true | If true, allows to align to nearby items when converting. | |
| diagram.convert.match-text-size | boolean | false | If true, enable scaling font so that on convert typeset text size fits handwritten text one. | |
| diagram.convert.text-size-scale | number | 1.25 | When diagram.convert.match-text-size is activated, sets the text scale value. Relevant values are within range 1 to 2. The larger the scale, the less font sizes are used. The closer to 1, the most linear the scale is, thus using more font sizes. If you set a value less than or equal to 1, the default value 1.25 is used. | |
| diagram.enable-sub-blocks | boolean | true | If true, Diagram parts contain accessible sub-blocks that describe the diagram content. | |
| diagram.eraser.radius | number | 3 | Radius of the eraser tool in mm. | |
| diagram.eraser.show | boolean | true | If true, a halo shows up at eraser position. | |
| diagram.eraser.erase-precisely | boolean | false | If false, the eraser removes any object (character, shape, line…) it touches, else it only erases ink portions within its trajectory. | |
| diagram.eraser.dynamic-radius | boolean | false | If false, the eraser is fixed, its value is the radius. If true, the eraser size is dynamic and grows with the speed. | |
| diagram.import.jiix.action | string | update | Possible values are update, add and replace. See import for details. | |
| diagram.session-time | number | 1000 | Time interval (in milliseconds) between the last pen up event and subsequent contentChanged() notifications. | |
| diagram.pen.gestures | string array | { scratch-out, strike-through, insert, join } | A string array containing any of the enabled gestures: {scratch-out, underline, insert, join, long-press, strike-through, surround}. | |
| diagram.recognition.feedback | string array | [“animation-fill”] | When shape recognition is enabled, this sets whether shapes should be highlighted temporarily. By default, there is an animation. To disable the animation, set to an empty value. | |
| diagram.selection.feedback | string | animate | A string containing none, one or more of {“animate”, “show-grabbed-handle-only”}. It sets the appearance of selection boxes: “animate” adds a short animation in the box states transition and “show-grabbed-handle-only” hides the box handles that are not used when manipulating the box. | |
| diagram.selection.lasso-outline | string | as-drawn | Possible values are {“as-drawn”, “fitted”}. It sets the appearance of the lasso: “as-drawn” keeps the lasso strokes as drawn by users, while “fitted” redraws the lasso outline to fit the lasso content. | Yes |
| diagram.z-order.highlight | string | default | Possible values are {“default”, “main”}. Indicates whether highlighter strokes are set at the back of the ink (default behavior) or remain in the main layer of writing (main behavior) . | |
| diagram.rotation | string array | [“shape”,”image”] | String value among: [ “shape”, “image” ] listing the items that can be rotated with a handle. | |

You can also configure interactivity, as described below.

## Raw Content

| Key | Type | Default value | Description |
| --- | --- | --- | --- |
| raw-content.configuration.analyzer.bundle | string | raw-content | Configuration bundle to be used for ink analysis (name of the *.conf file). By default, the bundle is the legacy one, working on all platforms. Other possible value is raw-content2 to use to our latest analyzer (not yet available on all platforms, check platforms for more details). |
| raw-content.configuration.analyzer.name | string | text-block | Configuration name for ink analysis, within the bundle (configuration within the *.conf file). |
| raw-content.configuration.shape.bundle | string | diagram | Configuration bundle to be used for shape recognition (name of the *.conf file). |
| raw-content.configuration.shape.name | string | shape | Configuration name for shape recognition, within the bundle (configuration within the *.conf file). |
| raw-content.configuration.text.bundle | string | ${lang} | Configuration bundle to be used for text recognition (name of the *.conf file). |
| raw-content.configuration.text.name | string | text | Configuration name for text recognition, within the bundle (configuration within the *.conf file). |
| raw-content.configuration.math.bundle | string | math | Configuration bundle to be used for math recognition (name of the *.conf file). By default, the bundle is the legacy one, working on all platforms. Other possible value is math2 to use to our latest math recognition (not yet available on all platforms, check platforms for more details). |
| raw-content.configuration.math.name | string | standard | Configuration name for math recognition, within the bundle (configuration within the *.conf file). |
| raw-content.classification.types | string array | ["text", "drawing"] | Controls the list of content types that can be output by the ink strokes classifier. If content types are removed from this list, the corresponding strokes are output as part of the most likely alternative choice among the remaining content types. Possible values are text, shape, math and drawing. Note that math requires the use of the latest technology with math2 for math bundle, and raw-content2 for analyzer bundle. (see above) |
| raw-content.recognition.types | string array | <empty> | Defines the type of recognition that will be performed on this content and the result that will be available in the JIIX export. Possible values are text, math and shape. |
| raw-content.convert.types | string array | [ "text", "math", "shape" ] | Defines which types of blocks respond to convert operations. Blocks whose types are not listed here remain unaffected by convert operations. Possible values are text, math and shape. |
| raw-content.convert.shape-on-hold | boolean | false | If true, Raw content shape conversion will be automatically triggered by holding the pen in position after drawing the shape. |
| raw-content.convert.snap | boolean | false | If true, allows to align to nearby items when converting. |
| raw-content.eraser.radius | number | 3 | Radius of the eraser tool in mm. |
| raw-content.eraser.erase-precisely | boolean | true | If false, the eraser removes any object it touches, else it only erases ink portions within its trajectory. |
| raw-content.eraser.dynamic-radius | boolean | false | If false, the eraser is fixed, its value is the radius. If true, the eraser size is dynamic and grows with the speed. |
| raw-content.eraser.show | boolean | true | If true, a halo shows up at eraser position. |
| raw-content.guides.show | string array | <empty> | Describes which alignment guides should be shown. Possible values are alignment, text, square, square-inside, image-aspect-ratio, rotation. |
| raw-content.guides.snap | string array | <empty> | Describes which alignment guides should be used for snapping, i.e. there is an attraction to these guides when the shapes are moved. Possible values are alignment, text, square, square-inside, image-aspect-ratio, rotation. |
| raw-content.highlight-text | boolean | true | If true, allows semantic highlighter on recognized text. |
| raw-content.import.jiix.action | string | add | Possible values are add and replace. See import for details. |

| raw-content.pen.gestures | string array | <empty> | A string array containing any of the enabled gestures: {scratch-out, underline, insert, join, long-press, strike-through, surround}. By default, it is empty, so no gesture is enabled. |
| --- | --- | --- | --- |
| raw-content.auto-connection | boolean | false | If true, allows auto connection of shapes and connectors |
| raw-content.edge.policy | string array | [“default-with-drag”] for Editor, [] for OffscreenEditor | String value among: “default” or “default-with-drag” defining shape enhancement policy in a Raw Content with Editor. By default it is “default-with-drag” which enables shape enhancement. Setting it is “default”, corresponding to a Diagram like behavior. To benefit from this feature, auto connection must be enabled (see raw-content.auto-connection configuration). |
| raw-content.shape.snap-axis | string array | <empty> | String value among: [ “triangle”, “rectangle”, “rhombus”, “parallelogram”, “polygon”, “ellipse” ]. Indicates the kind of shapes which will snap to X/Y axis when drawn or rotated. To benefit from this feature, auto connection must be enabled (see raw-content.auto-connection configuration) |
| raw-content.recognition.feedback | string array | <empty> | When shape recognition is enabled, this sets whether shapes should be highlighted temporarily. By default, there is no animation. To enable the animation, set to [“animation-fill”]. |
| raw-content.selection.feedback | string | animate | A string containing none, one or more of {“animate”, “show-grabbed-handle-only”}. It sets the appearance of selection boxes: “animate” adds a short animation in the box states transition and “show-grabbed-handle-only” hides the box handles that are not used when manipulating the box. |
| raw-content.selection.lasso-outline | string | as-drawn | Possible values are {“as-drawn”, “fitted”}. It sets the appearance of the lasso: “as-drawn” keeps the lasso strokes as drawn by users, while “fitted” redraws the lasso outline to fit the lasso content. |
| raw-content.z-order.highlight | string | default | Possible values are {“default”, “main”}. Indicates whether highlighter strokes are set at the back of the ink (default behavior) or remain in the main layer of writing (main behavior) . |
| raw-content.rotation | string array | [“shape”,”image”] | String value among: [ “shape”, “image” ] listing the items that can be rotated with a handle. To benefit from this feature on handwritten shapes, shape recognition must be activated (see raw-content.recognition.types) and interactions must be allowed on handwritten content (see raw-content.interactive-items configuration). Note that raw-content.rotation is enabled by default on shape for OffscreenEditor. |

You can also configure interactivity, as described below.

## Interactivity customization for Raw Content and Diagram

The following keys allow you to choose the interactive blocks, define the interactions upon tap and double tap on these interactive blocks and their visual feedbacks.
The keys names are similar for Raw Content and Diagram, with respective raw-content. and diagram. prefixes. Example: raw-content.interactive-blocks.converted and diagram.interactive-blocks.converted.

| Keys | Type | Default value | Description |
| --- | --- | --- | --- |
| interactive-blocks.auto-classified | string array | <empty> | Defines which kind of blocks becomes interactive immediately after being classified by the automatic classifier (usually immediately after their creation). Possible values are text, shape, drawing and all. |
| interactive-blocks.manually-classified | string array | [“all”] | Defines which kind of blocks becomes interactive immediately after being programmatically classified using the setSelectionType API. Possible values are text, math, shape, drawing and all. |
| interactive-blocks.converted | string array | [“all”] | Defines which kind of blocks becomes interactive after being converted. Possible values are text, math, shape, drawing and all. |
| interactive-blocks.select-on-tap | boolean | false | If true, allows interactive blocks to be selected on tap. |
| interactive-blocks.unselect-on-tap | boolean | true | If true, allows selected interactive blocks to be unselected when tapped again. |
| interactive-blocks.convert-on-double-tap | boolean | true | If true, allows interactive blocks to be converted on double-tap. |
| interactive-blocks.feedback | string array | <empty> | Defines for which kind of blocks a dedicated visual feedback is displayed to identify specific interactive blocks, depending on their type. When enabled, the feedback is a distinct border on math and text blocks, and a background-fill on shape blocks. Possible values are text, math and shape. |
| interactive-blocks.feedback-hints | string array | <empty> | Defines for which kind of blocks a dedicated visual feedback hint is displayed. Possible values are text and math. When enabled, the feedback is a “Σ” symbol for math blocks and a “T” letter for text blocks. |

## Text Document

The configurations described above also apply respectively to “Math”, “Drawing”, “Diagram” and “Raw Content” blocks within a Text Document, with the exception of the following configurations which apply to the entire Text Document:

| Key | Type | Default value | Description |
| --- | --- | --- | --- |
| text-document.convert.states | string array | [“digital-edit,”digital-publish”] | Sets the target states that are available on double tap: Possible values are “digital-edit”, “digital-publish” and “handwriting”. To allow conversion only to DigitalEdit, set [“digital-edit”]. To allow conversion first to DigitalEdit then to DigitalPublish, set [“digital-edit”,”digital-publish”]. To prevent conversion on double tap, set [“handwriting”]. |
| text-document.enable-sub-blocks | boolean | true | If true, Raw Content and Diagram blocks contain accessible sub-blocks that describe the blocks contents. |
| text-document.eraser.radius | number | 3 | Radius of the eraser tool in mm. |
| text-document.eraser.show | boolean | true | If true, a halo shows up at eraser position. |
| text-document.eraser.erase-precisely | boolean | false | If false, the eraser removes any object it touches in Text Document blocks, else it only erases ink portions within its trajectory. |
| text-document.eraser.dynamic-radius | boolean | false | If false, the eraser is fixed, its value is the radius. If true, the eraser size is dynamic and grows with the speed. |
| text-document.slice-gesture.enable | boolean | true | Set to false, to disable the slice gesture that allows adding a freeform section as a Raw Content block into a Text Document part. |

## Offscreen Editor

The following options apply to the Offscreen Editor object.

| Key | Type | Default value | Description |
| --- | --- | --- | --- |
| offscreen-editor.history-manager.enable | boolean | false | If true, associate a HistoryManager to an OffscreenEditor on creation. |

## Recognizers

The following options apply to the Recognizer objects.

### Common

| Key | Type | Default value | Description |
| --- | --- | --- | --- |
| recognizer.configuration-manager.search-path | string array | <empty> | List of directories where the configuration files (*.conf) are stored. |
| recognizer.result.default-format | string | “application/vnd.myscript.jiix” | Defines the format of the result received on IRecognizerListener resultChanged notification. It is one of the Recognizer result supported Mime types. |
| recognizer.lang | string | en_US | Defines the language for text recognition. |

### Text Recognizer

| Key | Type | Default value | Description |
| --- | --- | --- | --- |
| recognizer.text.configuration.bundle | string | ${recognizer.lang} | Configuration bundle to be used (name of the *.conf file). |
| recognizer.text.configuration.name | string | text | Configuration name, within the bundle (configuration within the *.conf file). Possible ready-to-use text configurations are text and text-superimposed. For more details, see resources section. |
| recognizer.text.guides.enable | boolean | false | If true, guides are used for recognition operation. |
| recognizer.text.guides.line-gap-mm | number | 0 | Defines guides spacing in mm in the Text recognizer (ignored if recognizer.text.guides.enable is false). |
| recognizer.text.guides.origin-y-mm | number | 0 | Defines the y position of the first guide in the Text recognizer (ignored if recognizer.text.guides.enable is false). |

### Gesture Recognizer

| Key | Type | Default value | Description |
| --- | --- | --- | --- |
| recognizer.gesture.tap.spacing-mm | number | 3 | Defines the distance in mm between two taps to determine double tap. |
| recognizer.gesture.disabled-gestures | string array | <empty> | Defines the gestures to be disabled (all enabled by default). String value among: [ “tap”, “double-tap”, “long-press”, “top-bottom”, “bottom-top”, “left-right”, “right-left”, “scratch”, “surround” ] |

### Math Recognizer

| Key | Type | Default value | Description |
| --- | --- | --- | --- |
| recognizer.math.configuration.bundle | string | math2 | Configuration bundle to be used (name of the *.conf file). |
| recognizer.math.configuration.name | string | standard | Configuration name, within the bundle (configuration within the *.conf file). |
| recognizer.configuration-manager.custom-resources.math.standard | string array | <empty> | List of file paths where the Math Recognizer custom SK files (*.res) are stored. |

### Shape Recognizer

| Key | Type | Default value | Description |
| --- | --- | --- | --- |
| recognizer.shape.beautification.enable | boolean | true | If true, enable the beautification of the shape recognition result (selected candidate only) |
| recognizer.shape.configuration.shape.bundle | string | shape | Configuration bundle to be used for shape recognition (name of the *.conf file). |
| recognizer.shape.configuration.shape.name | string | shape | Configuration name for shape recognition, within the bundle (configuration within the *.conf file). |

### Raw Content Recognizer

| Key | Type | Default value | Description |
| --- | --- | --- | --- |
| recognizer.raw-content.classification.types | string array | [ "text", "math", "shape", "decoration", "drawing"] | Controls the list of content types that can be output by the ink strokes classifier. If content types are removed from this list, the corresponding strokes are output as part of the most likely alternative choice among the remaining content types. |
| recognizer.raw-content.recognition.types | string array | [ "text", "math", "shape", "decoration"] | Controls the list of content types that are recognized after classification. |
| recognizer.raw-content.configuration.analyzer.bundle | string | raw-content2 | Configuration bundle to be used for ink analysis (name of the *.conf file). |
| recognizer.raw-content.configuration.analyzer.name | string | standard | Configuration name for ink analysis, within the bundle (configuration within the *.conf file). |
| recognizer.raw-content.configuration.shape.bundle | string | shape | Configuration bundle to be used for shape recognition (name of the *.conf file). |
| recognizer.raw-content.configuration.shape.name | string | shape | Configuration name for shape recognition, within the bundle (configuration within the *.conf file). |
| recognizer.raw-content.configuration.math.bundle | string | math2 | Configuration bundle to be used for shape recognition (name of the *.conf file). |
| recognizer.raw-content.configuration.math.name | string | standard | Configuration name for shape recognition, within the bundle (configuration within the *.conf file). |
| recognizer.raw-content.configuration.text.bundle | string | ${recognizer.lang} | Configuration bundle to be used for text recognition (name of the *.conf file). |
| recognizer.raw-content.configuration.text.name | string | text | Configuration name for text recognition, within the bundle (configuration within the *.conf file). |
| recognizer.raw-content.shape.beautification.enable | boolean | true | If true, enable the beautification of the shape recognition result (selected candidate only) |

## Handwriting Generation

| Key | Type | Default value | Description |
| --- | --- | --- | --- |
| handwriting-generation.init.resource | String | en-hw-gen.res | The resource name to be used for the handwriting generation: possible values are en-hw-gen.res for English text and zh-hw-gen.res for Chinese text. The folder path containing this .res file must be set by using the configuration-manager.search-path value. |
| handwriting-generation.session.line-gap-mm | number | 15 | The gap in mm between two lines of generated handwriting text. |
| handwriting-generation.session.origin-y-mm | number | 0 | The y position in mm of the first line of generated handwriting text. |
| handwriting-generation.session.origin-x-mm | number | If not defined, fall back to handwriting-generation.session.left-x-mm value. | The x position in mm of the first line of generated handwriting text. |
| handwriting-generation.session.left-x-mm | number | 0 | The x position in mm of the other lines of generated handwriting text. |
| handwriting-generation.session.width-mm | number | 0 | The width in mm for the clipping/alignment of generated handwriting text. If the value is 0, there is no width limit: generated lines are aligned with input (no reflow). |
| handwriting-generation.session.x-height-mm | number | 5 | The x-height in mm of the generated text. |

1. This setting only affects packages created or opened after the modification. ↩
2. This setting only affects Recognizer JIIX export: It is ignored by the Editor and the OffscreenEditor objects. ↩
3. this setting is ignored by Raw Content Recognizer JIIX export, as spans are always present in that case. ↩

---

## JIIX

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/reference/jiix/*

JIIX format reference 

Reference of the JSON Interactive Ink eXchange format (JIIX) version 3.

## Content

JIIX is an exchange format to export, share and re-import the internal semantics of the Interactive Ink model.

As such, it is designed to host information about:

- Content - strokes, glyphs and graphical primitives
- Semantic interpretation of the content, including lists
- Style information - decorations, color, width, font, etc.

When exporting JIIX from iink SDK, depending on the use case, you may sometimes want to only retrieve part of this information. This is
managed at configuration level, via the following keys:

- export.jiix.bounding-box - Export item bounding boxes
- export.jiix.strokes - Export ink strokes
- export.jiix.glyphs - Export converted glyphs
- export.jiix.primitives - Export shape primitives (lines, circles, etc.)
- export.jiix.style - Export detailed styling information (color, width, font, etc.)
- export.jiix.math-label - Export the LaTeX label of the Math block.
- export.jiix.text.chars - Export detailed information about the characters in the text interpretation
- export.jiix.text.words - Export detailed information about the words in the text interpretation
- export.jiix.text.spans - Export detailed recognition information per line in the text interpretation.
- export.jiix.deprecated.text.linebreaks - Export detailed information about the line breaks within a text.
- export.jiix.text.structure - Export detailed information about the text layout structure for Text blocks.
- export.jiix.ids - Export items ids.
- export.jiix.ranges - Export ink strokes ranges when using a Raw Content Recognizer.
- export.jiix.shape.candidates - Export shape candidates when using a Shape Recognizer.

For more information about these parameters, including default values, refer to the configuration reference.

## Versioning

The version of the format that the current document conforms to is given by the version property of the root of the JSON document
(as the root of the document corresponds to the root block of the exposed content block hierarchy, the version property belongs
to this root block).

| Description | Content | Note |
| --- | --- | --- |
| Version of the JIIX format | A string identifying the current iteration of the format | This property was added with iink SDK 1.3. JIIX documents before 1.3 do not have this property |

For example, if the root block is a “Text” block, we will have something like:

```json
{
"version": "3",
"type": "Text",
"bounding-box": { ... },
"label": "Hello world!",
"words": [ ... ],
"id": "MainBlock"
}
```

## Unit system

Units are not explicitly provided in a JIIX document.

For system coordinates, they shall be understood as model units, that is to say millimeters. The actual
rendering of a JIIX document on the screen will then depend on the dpi and any other parameter (zoom, offset) used to configure the renderer.

The angles are specified in radians.

## Structure

### Block hierarchy

JIIX documents are organized as a hierarchy of JSON objects (called “Blocks” in this page) that mirrors the block hierarchy of a content
part. Each object has a specific type string property identifying it as a text block, a diagram block, a math node, etc. and defining
the block semantics.

For example, a simple diagram may aggregate a text label and a rectangular node:

```json
{
"type": "Diagram",
"elements": [ {
"type": "Text",
...
}, {
"type": "Node",
"kind": "rectangle",
...
} ],
...
}
```

This semantics, in turn defines how sub-blocks are aggregated. For example :

- A Diagram block will host an array of “Diagram Item” blocks under its elements property.
- A Math block will host an array of “Math Node” blocks under its expressions property.
- A generic Container block will host its sub-blocks under a children property.
- …

To know the precise semantics of a given type of block, please refer to its detailed description below. 

### Properties common to blocks

Whatever their types, all blocks share the following common properties:

| Property | Description | Content | Note |
| --- | --- | --- | --- |
| id | Block unique reference in the context of the document | A string | |
| bounding-box | Extent of the block | x, y, width, height - 4 numerical values defining a rectangle which upper-left corner is positioned at coordinates (x, y) and of size (width, height) | Present in the JIIX export when export.jiix.bounding-box configuration is true |

For example, a simple text block can be represented as:

```json
{
"type": "Text",
"id": "MainBlock",
"bounding-box": {
"x": 20.43125,
"y": 31.272942,
"width": 9.9375,
"height": 8.9725456
},
...
}
```

Other potential properties depend on the type of the block. Refer to the “blocks” section for more details.

### Block content description

Block content is described using items, which represent what is actually visible when rendering the model.

## Items

Items are used to describe the content of blocks in terms of ink, glyphs or shape primitives.

Like blocks, items share common properties:

| Property | Description | Content |
| --- | --- | --- |
| type | Type of the item | stroke, line, arc or glyph |
| id | Item unique reference in the context of the document. | A string |

### Stroke item

A stroke item represents a standalone portion of ink, that is to say the trajectory of a writing tool between a pointer down and the
corresponding pointer up.

It has the following specific properties:

| Property | Description | Content | Note |
| --- | --- | --- | --- |
| timestamp | Precise date and time of the pointer down | Example: "2018-11-28 09:31:43.893000" | |
| X | X coordinates of the different points of the stroke, ordered from pointer down to pointer up | An array of numbers | |
| Y | Y coordinates of the different points of the stroke, ordered from pointer down to pointer up | An array of numbers. | |
| F | Force (a.k.a pressure) of the different points of the stroke, ordered from pointer down to pointer up | An array of numbers | |
| PT | Pen Tilt (a.k.a orientation elevation): The inclination of the stylus relative to the screen, ordered from pointer down to pointer up. Angles are between 0 and π/2 radians, where 0 is perpendicular to the screen, π/2 is flat on screen. | An array of numbers | Only present when set in the editor pointer events. |
| PO | Pen Orientation (a.k.a orientation azimuth): The direction in which the stylus is pointing relative to the screen, ordered from pointer down to pointer up. Angles are between -π and +π radians, where 0 is pointing up, -π/2 radians is pointing left, -π or π is pointing down, and π/2 radians is pointing right. | An array of numbers | Only present when set in the editor pointer events. |
| T | Time offset of the different points of the stroke in ms relatively to the timestamp of the stroke, ordered from pointer down to pointer up | An array of numbers | |

Example:

```json
{
"timestamp": "2024-10-04 14:21:48.681000",
"X": [ 90.5946655, 90.5946655, 90.5946655, 91.300972, 91.9794159, 92.351181, 92.351181 ],
"Y": [ 72.6014557, 72.6014557, 72.6014557, 72.6664429, 72.6107101, 72.4155731, 72.4155731 ],
"F": [ 0.683028102, 0.683028102, 0.336507946, 0.0451770462, 0.0451770462, 0.0393162407, 0.0393162407 ],
"PT": [ 0.576388836, 0.576388836, 0.576388836, 0.576388836, 0.576388836, 0.576388836, 0.576388836 ],
"PO": [ -1.18705797, -1.18705797, -1.18705797, -1.18705797, -1.18705797, -1.18705797, -1.18705797 ],
"T": [ 0, 0, 17, 25, 29, 34, 38 ],
"type": "stroke",
"id": "0000010001000d00ff00"
}
```

The number of elements in `X`, `Y`, `T`and `F`must be **strictly**identical. 

### Line item

A line item represents a converted line primitive, for instance the edge of a polygon.

It has the following specific properties:

| Property | Description | Content |
| --- | --- | --- |
| timestamp | Timestamp of the stroke that was converted into this primitive. | Example: "2018-11-29 10:03:05.980000". |
| x1 | X coordinate of the first point defining the line | A number |
| y1 | Y coordinate of the first point defining the line | A number |
| x2 | X coordinate of the second point defining the line | A number |
| y2 | Y coordinate of the second point defining the line | A number |
| startDecoration | Decoration of a “line” start point | arrow-head in case an arrow head is present, none when no decoration |
| endDecoration | Decoration of a “line” end point | arrow-head in case an arrow head is present, none when no decoration |

Example:

```json
{
"type": "line",
"timestamp": "2021-09-07 09:04:39.162000",
"x1": 24.8770332,
"y1": 19.7303886,
"x2": 66.5452576,
"y2": 19.7303886,
"startDecoration": "none",
"endDecoration": "none",
"id": "0000010001000300ff00"
}
```

### Arc item

An arc item represents a converted arc primitive, for instance a curved connector in a diagram or a portion of an ellipse.

It has the following specific properties:

| Property | Description | Content |
| --- | --- | --- |
| timestamp | Timestamp of the stroke that was converted into this primitive. | Example: "2018-11-29 10:03:05.980000" |
| cx | X coordinate of the arc center | A number |
| cy | Y coordinate of the arc center | A number |
| rx | x-axis or semi-major radius | A number (must be positive) |
| ry | y-axis or semi-minor radius | A number (must be positive) |
| phi | x-axis rotation angle | A number |
| startAngle | Start angle (prior to stretch and rotate) | A number |
| sweepAngle | Sweep angle (prior to stretch and rotate) | A number |
| startDecoration | Decoration of an “arc” item start point | arrow-head in case an arrow head is present, none when no decoration |
| endDecoration | Decoration of an “arc” item end point | arrow-head in case an arrow head is present, none when no decoration |

Example:

```json
{
"type": "arc",
"timestamp": "2021-09-06 13:56:41.110000",
"cx": 167.432373,
"cy": 105.229813,
"rx": 30.8068428,
"ry": 7.45266199,
"phi": 0,
"startAngle": 0,
"sweepAngle": 6.28318548,
"startDecoration": "none",
"endDecoration": "none",
"id": "0000300001008900ff00"
}
```

### Glyph item

A glyph item represents a converted typeset character.

It has the following specific properties:

| Property | Description | Content | Note |
| --- | --- | --- | --- |
| timestamp | Timestamp of the stroke that was converted into this glyph | Example: "2018-11-28 13:37:03.514000" | |
| label | Character represented by the glyph | Example: "B" | |
| baseline | Baseline position | A number | Optional (not used for the glyphs present in a math context) |
| x-height | x height | A number | Optional (not used for the glyphs present in a math context) |
| square-root-ratio | Horizontal ratio between the size of the glyph and the “V” shape part of the square root | A number | Only for square roots |
| left-side-bearing | Glyph left side bearing | A number | |
| right-side-bearing | Glyph right side bearing | A number | |

Example:

```json
{
"type": "glyph",
"timestamp": "2021-09-06 13:55:37.298000",
"label": "2",
"bounding-box": {
"x": 39.1022644,
"y": 27.6022339,
"width": 1.92954254,
"height": 4.29965172
}
```

## Text interpretation

Text interpreted by iink SDK is represented by word, lines and character objects as part of a Text block.

### Word object

A word object represents the recognition of a word made by the MyScript engine. Note that to get such interpretation in JIIX export, your
need to set the export.jiix.text.words configuration option to true.

It has the following properties:

| Property | Description | Content | Note |
| --- | --- | --- | --- |
| label | Top recognition result associated with this word | A string | |
| reflow-label | Reflow behavior when the word is a linefeed (i.e. with a label = \n) | Possible values are “” (empty) and “ “ (one space) depending on whether a space should be inserted when removing this linefeed for reflow. | For inline math, the reflow-label is the label where “\n” has been replaced by “ “ (one space). For more details and an example, see RawContent blocks |
| refs | When the word is inline math, gives the lists of id of its Math items. | An array of item id | For more details and an example, see RawContent blocks |
| candidates | List of recognition candidates associated with this word | An array of strings | |
| bounding-box | Extent of the word. | x, y, width, height - 4 numerical values defining a rectangle which upper-left corner is positioned at coordinates (x, y) and of size (width, height). | Present in the JIIX export when export.jiix.bounding-box configuration is true. |
| items | Ink and/or glyphs composing the word. | An array of stroke and/or glyph items | Strokes only present in JIIX export when export.jiix.strokes is configured to true, glyphs only present when export.jiix.glyphs is configured to true |
| first-char | Index of the first character contained in this word. | An integer, representing the index of a character object in the Text block. | Only present in the JIIX export when export.jiix.text.chars is configured to true |
| last-char | Index of the last character contained in this word. | An integer, representing the index of a character object in the Text block | Only present in the JIIX export when export.jiix.text.chars is configured to true |

Examples:

- Example corresponding to the word hello:

```json
{
"label": "hello",
"candidates": [ "hello", "hells", "hellor", "helle", "kello" ],
"first-char": 0,
"last-char": 4,
"bounding-box": {... },
"items": [ ... ]
}
```

- Linefeed example, corresponding to the word \n:

```json
{
"label": "\n",
"reflow-label": " "
}
```

### Character object

A character object represents the recognition of a character made by the MyScript engine. Note that to get such interpretation in JIIX
export, your need to set the export.jiix.text.chars configuration option to true.

It has the following properties:

| Property | Description | Content | Note |
| --- | --- | --- | --- |
| label | Recognition result associated with this char | A string | |
| candidates | List of recognition candidates associated with this character | An array of strings | |
| grid | Highlight area associated with this char | An array of 4 points, each containing x and y floating points coordinates | |
| bounding-box | Extent of the character | x, y, width, height - 4 numerical values defining a rectangle which upper-left corner is positioned at coordinates (x, y) and of size (width, height) | Present in the JIIX export when export.jiix.bounding-box configuration is true |
| items | Ink and/or glyphs composing the character | An array of stroke and/or glyph items | Strokes are only present in JIIX export when export.jiix.strokes is configured to true, glyphs are only present when export.jiix.glyphs is configured to true |
| word | Index of the word that contains this char | An integer | only present in the JIIX export when export.jiix.text.words is configuredto true |

Example:

```json
{
"label": "h",
"candidates": [ "h", "k", "b", "H" ],
"word": 0,
"grid": [ {
"x": 18.875834,
"y": 31.736748
}, {
"x": 25.118258,
"y": 31.736748
}, {
"x": 25.118258,
"y": 44.957951
}, {
"x": 18.875834,
"y": 44.957951
} ],
"bounding-box": { ... },
"items": [ ... ]
}
```

### Lines object

A lines object represents the information about lines analyzed by the MyScript engine.
It is present in the JIIX file when the export.jiix.text.spans or when the export.jiix.text.lines configuration option is set
to true.

The export.jiix.text.lines allows to get the geometric information of the line:

| Property | Description | Content | Note |
| --- | --- | --- | --- |
| baseline-y | y baseline position | A number | Only present when export.jiix.text.lines is configured to true |
| x-height | x height | A number | Only present when export.jiix.text.lines is configured to true |
| first-char | Index of the first character contained in this line. | An integer, representing the index of a character object in the Text block. | Only present when export.jiix.text.chars is configured to true |
| last-char | Index of the last character contained in this line. | An integer, representing the index of a character object in the Text block | Only present when export.jiix.text.chars is configured to true |

The export.jiix.text.spans allows to get the line recognition information: The line is considered as a collection separated into several span elements, each span being associated with a specific content type.
Thus each line consists in a label containing the recognition result associated with it and a spans object that is an array of spans.
A span object has the following properties:

| Property | Description | Content | Note |
| --- | --- | --- | --- |
| label | Recognition result associated with this span | A string | |
| type | Recognition type associated with this span | A string | The type can be Text or Math |
| bounding-box | Extent of the span | x, y, width, height - 4 numerical values defining a rectangle which upper-left corner is positioned at coordinates (x, y) and of size (width, height) | Only present in the JIIX export when export.jiix.bounding-box is true |

Example:

```json
"lines": [ {
"first-char": 0,
"last-char": 7,
"baseline-y": 15.1058693,
"x-height": 14.7235212,
"label": "hello $2 + 3$",
"spans": [ {
"type": "Text",
"bounding-box": {
"x": -65.5972595,
"y": -22.9333344,
"width": 102.510544,
"height": 41.6666679
},
"label": "hello"
}, {
"type": "Math",
"bounding-box": {
"x": 64.2636673,
"y": -8.46666718,
"width": 71.9609299,
"height": 30.9333344
},
"label": "2 + 3"
} ]
}]
```

## Style

The JIIX format can contain styling information. These encompass:

- CSS properties that you explicitly assign to the pen (dynamic styles)
- Style classes that you assign to the pen (pen style classes)
- Classes and styles automatically set by iink SDK when decorations are detected.

Themes, that are local to your editor, will not be exported. 

If you are exporting content, you need to set the export.jiix.style configuration key to true to get style
information.

### Item span styling

Blocks like Drawing and text/math/non-text raw content items can be seen as an ordered collection
of strokes. Such a collection can be styled via the definition of “item spans”, each span associating a specific style to a range of items.

Item spans have the following properties:

| Property | Description | Content |
| --- | --- | --- |
| first-item | Index of the first item in the span | A number (positive or null) |
| last-item | Index of the last item in the span | A number (positive or null) |
| class | Name of the CSS class attached to the items in the span | A string |
| style | Inline CSS style that “overrides” any default style | A string |

For example, if we write 2 strokes with pen style class set to “greenThickPen” then 2 more strokes with no pen style class but pen style set to “color : #FF324233”, we obtain something like:

```json
{
"first-item": 0,
"last-item": 1,
"class": "greenThickPen"
}
```

and

```json
{
"first-item": 2,
"last-item": 3,
"style": "color: #FF324233"
}
```

Note that an item may be contain both class and style indications, or none of them if default styling applies.

### Text span styling

Text blocks can be seen as an ordered collection of characters. Such a collection can be styled via the definition of
“character spans”, each span associating a specific style to a range of characters.

Item spans have the following properties:

| Property | Description | Content | Note |
| --- | --- | --- | --- |
| first-char | Index in the text of the first character in the span | A number (positive or null) | Only present when export.jiix.text.chars is configured to true |
| last-char | Index in the text of the last character in the span | A number (positive or null) | Only present when export.jiix.text.chars is configured to true |
| class | Name of the CSS class attached to the characters in the span | A string | |
| style | Inline CSS style that “overrides” any default style | A string | |

For example, text underlined by a gesture may get the following style:

```json
{
"first-char": 0,
"last-char": 12,
"class": "text-emphasis1",
"style": "color: #000000FF; -myscript-text-decoration-color: #000000FF; -myscript-text-decoration-background-color: #FFED2666"
}
```

### Nodes styling

Blocks like math and diagram nodes, as well as diagram connectors are
independently styled.

They can directly have the following properties:

| Property | Description | Content |
| --- | --- | --- |
| class | Name of the CSS class attached to the node | A string |
| style | Inline CSS style that “overrides” any default style for the node | A string |

For example, a math node can be styled as follows:

```json
{
"type": "number",
"id": "math/170",
"label": "3",
"value": 3,
"items": [ ... ],
"bounding-box": { ... },
"class": "greenThickPen"
}
```

## Blocks

This section lists all available blocks of the hierarchy, their properties and particularities, if any.

### Container block

A block of type Container groups children blocks together.

It has the following specific property:

| Property | Description | Content |
| --- | --- | --- |
| children | List of blocks within this container block | An array of blocks |

For example, in the JIIX export of a “Text Document” part composed of two paragraphs of text, each paragraph will correspond to a text block
and both will be grouped as the children of a same container block:

```json
{
"type": "Container",
"id": "MainBlock",
"bounding-box": { ... },
"children": [ {
"type": "Text",
...
}, {
"type": "Text",
...
} ],
...
}
```

No assumption is made about the type of children blocks. 

### Diagram block

A block of type Diagram groups together the different internal blocks of an individual diagram.

It has the following specific property:

| Property | Description | Content |
| --- | --- | --- |
| elements | Array of recognized diagram items. | An array of Diagram item blocks |

For example, a diagram may be composed of a Text label and of a diagram Node corresponding to a rectangle:

```json
{
"type": "Diagram",
"id": "4",
"bounding-box": { ... },
"elements": [ {
"type": "Text",
...
}, {
"type": "Node",
"kind": "rectangle",
...
} ],
...
}
```

### Diagram item blocks

Diagram item blocks collectively form a family of blocks of different types describing the semantic structure of a diagram: connectors,
text blocks, geometric shapes, etc. There is no actual “Diagram Item” type.

These blocks share the following common properties:

| Property | Description | Content | Note |
| --- | --- | --- | --- |
| type | Diagram item type | Node, Edge, Polyedge or Text | |
| parent | Diagram item parent item (if any) | A diagram item numerical id | |
| items | Ink and/or converted shape primitives composing the item | An array of stroke, line and/or arc items | Strokes are only present in JIIX export when export.jiix.strokes is configured to true, lines and arcs are only present when export.jiix.primitives is configured to true |

Diagram nodes and connectors (i.e. with type node, edge or polyedge) will get the following styling properties:

| Property | Description | Content |
| --- | --- | --- |
| class | Name of the CSS class attached to the node | A string |
| style | Inline CSS style that “overrides” any default style for the node | A string |

Style is only present in then JIIX export when export.jiix.style is configured to true.

Example:

```json
{
"id": "diagram/3/242",
"type": "Node",
"parent": 12,
"bounding-box": { ... },
"items": [ ... ],
... specific properties ...
}
```

Although diagram item blocks have an `id`property like other blocks, their identifier is a number with a prefix identifying their parents and not a string. 

➤ Diagram and Raw Content Node block

An item of type Node is associated with a particular shape, an optional label, and may host child items. This is modeled by the
following properties:

| Property | Description | Content |
| --- | --- | --- |
| kind | Diagram item Sub-type. | rectangle, rhombus, polygon, circle, ellipse or doodle |
| label-element | id of the diagram item of type Text that describes the label associated with the item. | A diagram item numerical id |
| children | Array of child diagram items associated with the item | An array of diagram items numerical ids |

Depending on its “kind”, the item will have specific properties:

- If "kind": "rectangle"


x - X coordinate of the upper-left corner of the rectangle.

y - X coordinate of the upper-left corner of the rectangle.

width - Width of the rectangle.

height - Height of the rectangle.

orientation - x-axis rotation angle of the selection box of the rectangle (when shape rotation is active).
- If "kind": "rhombus"


points - Array containing the 4 {x, y} points describing the rhombus.

orientation - x-axis rotation angle of the selection box of the rhombus (when shape rotation is active).
- If "kind": "polygon"


points - Array of {x, y} points describing the polygon.

orientation - x-axis rotation angle of the selection box of the polygon (when shape rotation is active).
- If "kind": "circle"


cx - X coordinate of the circle center.

cy - Y coordinate of the circle center.

r - Radius of the circle.

orientation - x-axis rotation angle of the selection box of the circle (when shape rotation is active).
- If "kind": "ellipse" : an axis aligned ellipse.


cx - X coordinate of the ellipse center.

cy - Y coordinate of the ellipse center.

rx - X radius of the ellipse.

ry - Y radius of the ellipse.

orientation - x-axis rotation angle of the selection box of the ellipse (when shape rotation is active).
- If "kind": "doodle"

No specific property describes a doodle.

Note: As doodles are not converted, items will never contain shape primitives.

For example, the following node represents a rectangle in a diagram, associated with a text label:

```json
"type": "Node",
"kind": "rectangle",
"orientation": -0.0148907145,
"label-element": "diagram/22",
"children": [ "diagram/22" ],
"id": "diagram/13",
"bounding-box": {
"x": 61.7742119,
"y": 51.8420029,
"width": 82.0821991,
"height": 36.4551468
}
```

➤ Diagram Edge block

A diagram item of type Edge connects other diagram items.

| Property | Description | Content | Note |
| --- | --- | --- | --- |
| kind | Connector sub-type | line or arc | |
| children | Array of children diagram items associated with the item | An array of diagram items numerical ids | |
| connected | List of the diagram items connected to this edge | An array of diagram items numerical ids | |
| ports | List of the relative hooking positions of the diagram items connected to this edge. | A list of numbers between 0 and 1. | |
| p1Decoration | Decoration of a “line” edge first point | arrow-head in case an arrow head is present | This property is absent if there is no decoration and only applies to “line” edges |
| p2Decoration | Decorationof a “line” edge second point | arrow-head in case an arrow head is present | This property is absent if there is no decoration and only applies to “line” edges |
| startDecoration | Decoration of an “arc” edge start point | arrow-head in case an arrow head is present | This property is absent if there is no decoration and only applies to “arc” edges |
| endDecoration | Decoration of an “arc” edge end point | arrow-head in case an arrow head is present | This property is absent if there is no decoration and only applies to “arc” edges |

Example of a “straight” edge:

```json
{
"type": "Edge",
"kind": "line",
"connected": [ "diagram/12", "diagram/47" ],
"ports": [ 0, 0.521515965 ],
"id": "diagram/85",
"bounding-box": {... },
"x1": 81.9797897,
"y1": 49.3274384,
"x2": 146.199982,
"y2": 55.2804871,
"p2Decoration": "arrow-head"
}
```

Note that as a “line” connector, the edge includes x1, y1, x2 and y2 properties, defined the exact same way than in the case of line
items.

Example of a “curved” edge:

```json
{
"type": "Edge",
"kind": "arc",
"connected": [ "diagram/10", "diagram/53" ],
"ports": [ 0, 1 ],
"id": "diagram/105",
"bounding-box": { ... },
"items": [ ... ],
"cx": 120.779442,
"cy": 74.4197159,
"rx": 32.6964035,
"ry": 32.6964035,
"phi": 0.00504867753,
"startAngle": -1.82163024,
"sweepAngle": 3.53351736,
"endDecoration": "arrow-head"
}
```

Note that as an “arc” connector, the edge includes cx, cy, rx, ry, phi, startAngle and sweepAngle properties, defined the exact
same way than in the case of arc items.

➤ Diagram Polyedge block

A diagram item of type Polyedge connects other diagram items via several other edges. It is associated with the following properties:

| Property | Description | Content |
| --- | --- | --- |
| connected | List of the diagram items connected by this polyedge | An array of diagram items numerical ids. |
| edges | List of edges composing this polyedge | A list of diagram edge items |

Example of a polyedge gathering three edges together:

```json
{
"type": "Edge",
"kind": "polyedge",
"id": "diagram/65",
"connected": [ "diagram/37" ],
"edges": [ {
"type": "Edge",
"kind": "line",
...
}, {
"type": "Edge",
"kind": "line",
...
}, {
"type": "Edge",
"kind": "line",
...
} ]
}
```

➤ Diagram Text block

A diagram item of type Text combines the properties of a diagram item and those of a Text Block. It is styled using text
spans.

### Drawing block

A drawing block gathers raw digital ink.

It can have the following specific properties:

| Property | Description | Content | Note |
| --- | --- | --- | --- |
| items | Ink composing the block. | An array of strokes items | Strokes are present in JIIX export when export.jiix.strokes is configured to true |
| spans | List of item spans providing styling information | An array of item span objects | Style is only present in then JIIX export when export.jiix.style is configured to true |
| image | Image data when an image is added into a Text Document | An image object | |

Example:

```json
{
"type": "Drawing",
"id": "7",
"bounding-box": { ... },
"items": [ ... ],
"spans": [ ... ],
"image": { ... }
}
```

➤Drawing image object

When adding an image into a Text Document, a Drawing block is added that contains an image object with the following properties:

| Property | Description | Content |
| --- | --- | --- |
| url | url of the image. | The image filename (as stored into the package zip file). |
| mime-type | mime-type of the image. | Possible values are: image/jpeg, image/png and image/gif. |
| x | X coordinate of the upper-left corner of the image. | A number. |
| y | Y coordinate of the upper-left corner of the image. | A number. |
| width | Width of the image. | A number. |
| height | Height of the image. | A number. |

Example:

```json
"image": {
"url": "1630419125093723_20160701_212430.jpg",
"mime-type": "image/jpeg",
"x": 14.2750961,
"y": 52.8047333,
"width": 195.449829,
"height": 109.940521
}
```

### Math block

A block of type Math is associated with the following specific properties:

| Property | Description | Content | Note |
| --- | --- | --- | --- |
| expressions | Array of recognized Math expressions. | An array of math node blocks. | |
| label | Recognition result as a LaTeX string associated with this math block | A string | Only present when export.jiix.math-label is configured to true. |

Example:

```json
{
"type": "Math",
"id": "4",
"bounding-box": { ... },
"label": "\\cos \\dfrac{\\pi }{2}",
"expressions": [ ... ]
}
```

### Math Node block

A math node block describes a portion of a mathematical expression.
Depending on the math node type, a math node may contain other math nodes, in the operands property.

| Property | Description | Content | Note |
| --- | --- | --- | --- |
| type | Node type | A string | Example: +, -, number, square root, =, vertical operation, etc. |
| label | Label associated with the node, when it is different from type | A string | Example: 2.453..., √, θ, dx… |
| operands | Operands associated with the nodes, if any. | An array of math nodes | |
| solver-output | Signals that the node was added by the iink engine | A boolean | When not present this property is considered false |
| value | Numerical value associated to a given node | A number | Not present when the iink SDK solver could not solve this particular node |
| exact value | More accurate value associated to a given node | A number | Only present when a value is present and whenever relevant. Example for √2, “value”: 2.41421356 and “exact-value”: “2.414213562373095” are present, whereas for √4, only “value”: 2 is present. |
| items | Ink and/or glyphs composing the node | An array of stroke and/or glyph items | Strokes are only present in JIIX export when export.jiix.strokes is configured to true, glyphs are only present when export.jiix.glyphs is configured to true |
| error | Signals that the solver detected an error | A string | Possible values are: DivisionByZeroImpossible, IncompleteInput, Unsolved, InvalidInput and FailureToObtainAValidResult |
| class | Name of the CSS class attached to the node | A string | Style is only present in then JIIX export when export.jiix.style is configured to true |
| style | Inline CSS style that “overrides” any default style for the node | A string | Style is only present in then JIIX export when export.jiix.style is configured to true |

Example:

```json
{
"type": "+",
"id": "math/34",
"items": [ ... ],
"bounding-box": { ... },
"operands": [ ... ]
}
```

➤ Fence Math block

Math nodes of type fence have the following specific properties:

| Property | Description | Content | Examples |
| --- | --- | --- | --- |
| open symbol | Opening symbol of the fence. If this property is not set, indicates that no opening symbol was recognized | A string | (, [, { |
| close symbol | Closing symbol of the fence. If this property is not set, indicates that no closing symbol was recognized | A string | ), ], } |

➤ Matrix Math block

Math nodes of type matrix have the following specific properties:

| Property | Description | Content |
| --- | --- | --- |
| rows | Matrix content, row per row | An array of cells objects, each representing a row of the matrix |
| cells | Content of a row of the matrix | An array of math nodes |

➤ System Math block

Math nodes of type system have the following specific property:

| Property | Description | Content |
| --- | --- | --- |
| | | |
| expressions | Array of expressions within the system | An array of math nodes |

### Text Block

A block of type Text has the following specific properties:

| Property | Description | Content | Note |
| --- | --- | --- | --- |
| label | Recognition result associated with this text block | A string | Example: "label": "Hello how are you?" |
| words | List of recognized words | An array of word objects | Words are only present in then JIIX export when export.jiix.text.words is configured to true |
| chars | List of recognized characters | An array of character objects | Characters are only present in then JIIX export when export.jiix.text.chars is configured to true |
| spans | List of text spans providing styling information | An array of text span objects | Style is only present in then JIIX export when export.jiix.style is configured to true |
| linebreaks | List of explicit line breaks in the text block | An array of line index | Only present in then JIIX export when export.jiix.deprecated.text.linebreaks is configured to true |
| structure | Text layout structure | A structure object that is an array of text, list and divider items. | Only present in then JIIX export when export.jiix.text.structure is configured to true |

Although the `export.jiix.deprecated.text.linebreaks`option is still available, it is deprecated. So, we recommend you using the `export.jiix.text.structure`option to retrieve information about line breaks. 

Example:

```json
{
"type": "Text",
"id": "7",
"bounding-box": { ... },
"label": "hello",
"words": [ ... ],
"chars": [ ... ],
"spans": [ ... ]
}
```

MyScript iink SDK differentiates explicit from implicit line breaks. An explicit line break is detected each time the writer goes
back to the beginning of the next line but there was space to insert the word at the end of the previous line. An explicit line break is for
instance preserved by reflow operations. An implicit line break corresponds to the case the user went to a new line after the previous one
was fully filled (based on the view size).

➤Text line breaks

Let’s assume that we write something that visually looks like:

```plaintext
Hello
there!
This is a bit more than a full
line
```

We will assume that the third line takes the full width of the view.
The corresponding JIIX export when export.jiix.deprecated.text.linebreaks is configured to true will look like:

```json
{
"type": "Text",
"bounding-box": { ... },
"label": "Hello\nthere!\nThis iis a bit more than a full\nline",
"words": [ ... ],
"linebreaks": [ {
"line": 0
}, {
"line": 1
} ],
"version": "3",
"id": "MainBlock"
}
```

Notice the three line breaks in the main label. Via the linebreaks property, the JIIX format explicits that the line breaks on line 0 and
1 (the first two lines) are explicit line breaks.

➤Text structure

When the export.jiix.text.structure configuration is enabled, the JIIX file contains the text layout structure for Text blocks.
It consists in describing the way users organize their text: plain text, numbered or unnumbered list, empty lines.
This text layout information is stored into a structure objects that is an array of text-item, list-item and divider items.
The divider item corresponds to empty lines.

The text-item, list-item and divider objects have the following properties:

| Property | Description | Content | Note |
| --- | --- | --- | --- |
| id | Unique identifier of the item | A string | Only present for text-item and list-item |
| type | Type of the item | A string | Values can be text-item, list-item or divider |
| indentation | Amount of indentation before the item | A number | |
| text-indentation | Amount of indentation before the text contained in the item | A number | |
| first-char | Index of the first character contained in this item | An integer, representing the index of a character object in the Text block | Only present in the JIIX export when export.jiix.text.chars is configured to true |
| last-char | Index of the last character contained in this item. | An integer, representing the index of a character object in the Text block | Only present in the JIIX export when export.jiix.text.chars is configured to true |
| first-word | Index of the first word contained in this item. | An integer, representing the index of a word object in the Text block | Only present in the JIIX export when export.jiix.text.words is configured to true |
| last-word | Index of the last word contained in this item. | An integer, representing the index of a word object in the Text block | Only present in the JIIX export when export.jiix.text.words is configured to true |
| first-line | Index of the item first line | An integer | |
| last-line | Index of the item last line | An integer | |
| explicit-linebreak | Indicates whether the line creation is due a writer’s explicit line break | A boolean | Always true for dividers and list items, can be false for text items when they are started by a non explicit linebreak |

In addition, the list-item contains a bullet object with the following attributes:

| Property | Description | Content | Note | |
| --- | --- | --- | --- | --- |
| kind | Bullet kind of symbol or glyph | A string | Value can be bullet, letter, number or check | |
| first-char | Index of the bullet first character | An integer, representing the index of a character object in the Text block | Only present in the JIIX export when export.jiix.text.chars is configured to true | |
| last-char | Index of the bullet last character | An integer, representing the index of a character object in the Text block | Only present in the JIIX export when export.jiix.text.chars is configured to true | |
| first-word | Index of the bullet first word | An integer, representing the index of a word object in the Text block | Only present in the JIIX export when export.jiix.text.words is configured to true | |
| last-word | Index of the bullet last word | An integer, representing the index of a word object in the Text block | Only present in the JIIX export when export.jiix.text.words is configured to true | |
| first-line | Index of the bullet first line | An integer | | |
| last-line | Index of the bullet last line | An integer | | |

For example, let’s assume that we write something that visually looks like:

```plaintext
Hello
- How are you?
1. Fine
2. Good
A. Super
B. Extra
- Hello
How are you?
How are you? How are
you?
```

The corresponding JIIX file including the structure block would look like this file.

### Raw Content block

This section describes Raw Content blocks exported by `Editor`or `OffscreenEditor`objects. Raw Content blocks exported by `Raw Content Recognizer`are described [here](#raw-content-recognizer-block)

A Raw Content block corresponds to the output of raw digital ink analysis. It is meant to express the ink classification according to the raw-content.classification.types array, and the ink interpretation according to the raw-content.recognition.types array, as text, math and shape recognition results expressed as a hierarchy of items.

A block of type Raw Content has the following specific property:

| Property | Description | Content |
| --- | --- | --- |
| elements | Array of recognized (Node, Text and/or Math) items and non recognized Raw Content items, depending on raw-content.classification.types and raw-content.recognition.types values | An array of shape item blocks, Math item blocks, Text item blocks and Raw Content item blocks |

Example of output:

```json
{
"type": "Raw Content",
"bounding-box": { ... },
"elements": [ {
"type": "Node",
"kind": "rectangle", ...
}, {
"type": "Text",
"label": "hello", ...
}, {
"type": "Math",
"expressions": ...
}, {
"type": "Raw Content",
"kind": "non-text", ...
} ],
"id": "MainBlock",
"version": "3"
}
```

➤ Raw Content Text item block

When a Raw Content Text item block contains inline math, the math is represented as an external Math item block.
In addition to Text item blocks common properties, it also contains the following properties:

| Property | Description | Content | Note |
| --- | --- | --- | --- |
| children | Array of children Math item blocks associated with the Text item | An array of Math items numerical ids | |
| children-pos | The character indices of the external Math item blocks. | An array of integer | Only present in the JIIX export when export.jiix.text.chars is configured to true |

- The labels for the words, lines and spans have inlined math label delimited by $ where appropriate. The label for characters representing a Math item is an empty string.
- A word corresponding to inline math has a refs which gives the list of id of its corresponding Math items, and a reflow-label which is its label where \n has been replaced by space.

➤ Raw Content external Math item

In addition to Math item blocks common properties, a Raw Content external Math item contains a reference to its Text parent:

| Property | Description | Content |
| --- | --- | --- |
| parent | The Text parent item of this Math item | A Text item numerical id |

Example of output for a Raw Content with a Text block containing inline math:

```json
{
{
"type": "Raw Content",
"elements": [ {
"children": [ "raw-content/793", "raw-content/825" ],
"id": "raw-content/511",
"children-pos": [ 11, 13 ],
"type": "Text",
"label": "Operations $2+3$\n$7+12$ are additions",
"words": [ {
"label": "Operations",
"candidates": [ "Operations", "operations", "Operatiions", "Dperations", "Operatios" ],
"first-char": 0,
"last-char": 9
}, {
"label": " $2+3$\n$7+12$ ",
"refs": [ "raw-content/793", "raw-content/825" ],
"first-char": 10,
"last-char": 14,
"reflow-label": " $2+3$ $7+12$ "
}, {
"label": "are",
"candidates": [ "are", "we", "ae", "We", "Are" ],
"first-char": 15,
"last-char": 17
}, {
"label": " ",
"first-char": 18,
"last-char": 18
}, {
"label": "additions",
"candidates": [ "additions", "aaditions", "auditions", "audition", "addition" ],
"first-char": 19,
"last-char": 27
} ],
"chars": [ ... ],
"lines": [ ... ]
}, {
"parent": "raw-content/511",
"id": "raw-content/825",
"type": "Math",
"expressions": [ ... ]
}, {
"parent": "raw-content/511",
"id": "raw-content/793",
"type": "Math",
"expressions": [ ... ]
} ],
"id": "MainBlock",
"version": "3"
}
```

### Raw Content item block

In addition to common block properties, raw content item blocks also have the following specific properties:

| Property | Description | Content | Note |
| --- | --- | --- | --- |
| kind | Raw content item identified as representing ink data | text, math or non-text | |
| items | Items composing the block. | An array of items | Strokes are present in JIIX export when export.jiix.strokes is configured to true |

Example:

```json
{
"type": "Raw Content",
"kind": "text",
"id": "raw-content/13",
"bounding-box": { ... },
"items": [ ... ]
}
```

Although raw content item blocks have an `id`property like other blocks, their identifier is a number with a prefix identifying their parents and not a string. 

Styling of a raw content item block is similar to Drawing for text and non-text blocks without the recognition enabled,
otherwise it is similar as that of Diagram item blocks.

When adding an image into a RawContent, an image element is added that contains the following specific properties:

| Property | Description | Content |
| --- | --- | --- |
| image-id | Unique identifier of the image | A String. |
| url | url of the image. | The image filename (as stored into the package zip file). |
| mime-type | mime-type of the image. | Possible values are: image/jpeg, image/png and image/gif. |
| x | X coordinate of the upper-left corner of the image. | A number. |
| y | Y coordinate of the upper-left corner of the image. | A number. |
| width | Width of the image. | A number. |
| height | Height of the image. | A number. |
| orientation | x-axis rotation angle of the image (when image rotation is active). | A number. |

Example:

```json
{
"type": "Image",
"kind": "non-text",
"orientation": -0.458628416,
"id": "raw-content/37",
"bounding-box": {
"x": 195.51796,
"y": 23.953661,
"width": 92.950943,
"height": 112.844849
},
"image-id": "ImageId1697636709366167",
"url": "ImageId1697636709366167.png",
"mime-type": "image/png",
"x": 231.879929,
"y": 24.953661,
"width": 59.8457947,
"height": 95.468277,
}
```

When adding a placeholder into a RawContent, a Placeholder element is added that contains the following specific properties:

| Property | Description | Content |
| --- | --- | --- |
| image-id | Unique identifier of the image | A String. |
| url | url of the image. | The image filename (as stored into the package zip file). |
| user-data | User defined metadata | A String. |
| mime-type | mime-type of the image. | Possible values are: image/jpeg, image/png and image/gif. |
| x | X coordinate of the upper-left corner of the image. | A number. |
| y | Y coordinate of the upper-left corner of the image. | A number. |
| width | Width of the image. | A number. |
| height | Height of the image. | A number. |

Example:

```json
{
"type": "Placeholder",
"kind": "non-text",
"id": "raw-content/37",
"bounding-box": {
"x": 77.3406219,
"y": -12.4064779,
"width": 71.203125,
"height": 10.3078699
},
"image-id": "ImageId17248359471570692",
"url": "ImageId17248359471570692.png",
"mime-type": "image/png",
"user-data": "User provided this string",
"x": 78.3406219,
"y": -11.4064779,
"width": 69.203125,
"height": 8.30786991
}
```

## Recognizer blocks

### Gesture block

A Gesture block corresponds to the output of Gesture Recognizer analysis.

In addition to common block properties, a Gesture block also has the following specific property:

| Property | Description | Content |
| --- | --- | --- |
| gestures | Array of gesture items | An array of gesture items |

Example:

```json
{
"version": "3",
"type": "Gesture",
"gestures": [ ... ]
}
```

### gesture item block

In addition to common block properties, gestures item blocks also have the following specific properties:

| Property | Description | Content | Note |
| --- | --- | --- | --- |
| type | Gesture item identified as representing ink or touch gesture | A string | Possible values are none, bottom-top, top-bottom, right-left, left-right, scratch, surround, tap, double-tap and long-press. |

Example:

```json
"gestures": [ {
"type": "surround",
"strokes": [ {
"id": "ps6",
"bounding-box": {
"x": 13.5319223,
"y": 34.2388916,
"width": 24.574482,
"height": 16.1788025
}
} ],
"bounding-box": {
"x": 13.5319223,
"y": 34.2388916,
"width": 24.574482,
"height": 16.1788025
}
} ]
```

### Shape block

A Shape block corresponds to the output of Shape Recognizer analysis.

In addition to common block properties, a Shape block also has the following specific property:

| Property | Description | Content |
| --- | --- | --- |
| elements | Array of shape elements | An array of shape elements |

Example:

```json
{
"version": "3",
"type": "Shape",
"elements": [ ... ]
}
```

### Shape element

Shape elements contain the following properties:

| Property | Description | Content | Note |
| --- | --- | --- | --- |
| bounding-box | Extent of the shape | x, y, width, height - 4 numerical values defining a rectangle which upper-left corner is positioned at coordinates (x, y) and of size (width, height) | Present in the JIIX export when export.jiix.bounding-box configuration is true |
| shape | Item composing the shape. | A shape item | |
| candidates | List of recognition candidates associated with this shape | An array of shape items | Candidates are present in JIIX export when export.jiix.shape.candidates is configured to true. The first candidate in the array corresponds to the shape described on previous line. |
| items | List of stroke items associated with this shape | An array of stroke items | Strokes are present in JIIX export when export.jiix.strokes is configured to true |

Example:

```json
{
"bounding-box": { ... },
"shape": { ... },
"candidates": [ {...} ],
"items": [ {...} ]
}
```

### Shape item

Shape items contain the following properties:

| Property | Description | Content | Note |
| --- | --- | --- | --- |
| kind | recognized shape kind. | A string corresponding to one of the following shapes: line, polyline, polygon, triangle, isosceles triangle, right triangle, right isosceles triangle, equilateral triangle, quadrilateral, trapezoid, parallelogram, rhombus, rectangle, square, ellipse, circle, arc of ellipse, arc of circle, double arrow, arrow, polyline arrow, polyline double arrow, curved arrow, curved double arrow. | If no shape was recognized, value is rejected. |
| primitives | Primitives of the shape. | An array of shape primitives. | |

Example:

```json
"shape": {
"kind": "arrow",
"primitives": [ {
"type": "line",
"x1": 97.8697891,
"y1": 148.372635,
"x2": 151.793411,
"y2": 148.372635,
"startDecoration": "none",
"endDecoration": "arrow-head"
} ]
}
```

### Shape primitive

Shape primitives content depend on the shape kind:

- line primitive

For triangle, isosceles triangle, right triangle, right isosceles triangle, equilateral triangle, quadrilateral, trapezoid, parallelogram, rhombus, rectangle, square, primitives are an array of line primitives representing their edges and contain the properties:

| Property | Description | Content |
| --- | --- | --- |
| type | primitive type | line |
| x1 | X coordinate of the first point defining the line | A number |
| y1 | Y coordinate of the first point defining the line | A number |
| x2 | X coordinate of the second point defining the line | A number |
| y2 | Y coordinate of the second point defining the line | A number |

For line, polyline, double arrow, arrow, polyline arrow and polyline double arrow primitives are line primitives too, that contain the following additional properties:

| startDecoration | Decoration of a “line” start point | arrow-head in case an arrow head is present, none when no decoration |
| --- | --- | --- |
| endDecoration | Decoration of a “line” end point | arrow-head in case an arrow head is present, none when no decoration |

- arc primitive

For ellipse, circle, arc of ellipse, arc of circle primitives are an arc primitive representing their edge and contain the properties:

| Property | Description | Content |
| --- | --- | --- |
| type | primitive type | arc |
| cx | X coordinate of the arc center | A number |
| cy | Y coordinate of the arc center | A number |
| rx | x-axis or semi-major radius | A number (must be positive) |
| ry | y-axis or semi-minor radius | A number (must be positive) |
| phi | x-axis rotation angle | A number |
| startAngle | Start angle (prior to stretch and rotate) | A number |
| sweepAngle | Sweep angle (prior to stretch and rotate) | A number |

For curved arrow and curved double arrowprimitive is an arc too, that contains the following additional properties:

| startDecoration | Decoration of an “arc” item start point | arrow-head in case an arrow head is present, none when no decoration |
| --- | --- | --- |
| endDecoration | Decoration of an “arc” item end point | arrow-head in case an arrow head is present, none when no decoration |

### Raw Content Recognizer block

It corresponds to the output of raw digital ink analysis and recognition made by the Raw Content Recognizer.

It is meant to express a classification of ink corresponding to ink interpretation as text, shape, math, decoration, or drawing type depending on recognizer.raw-content.classification value.
Results are expressed as a hierarchy of items.

A block of type Raw Content has the common block properties, plus the following specific property:

| Property | Description | Content |
| --- | --- | --- |
| range | Only present in the JIIX export when export.jiix.ranges is configured to true | An array of ink intervals |
| elements | Array of items, which types depend on recognizer.raw-content.classification and recognizer.raw-content.recognition values | An array of Text, Shape, Math, Decoration and Drawing block objects |

Example:

```json
{
"version": "3",
"id": "MainBlock",
"type": "Raw Content",
"bounding-box": {
...
},
"range": [
{ "from": { "stroke": 0 }, "to": { "stroke": 135 } }
],
"elements": [ ... ]
}
```

- range

When the export.jiix.ranges configuration is enabled, every object in the JIIX file contains a range which is an array of ink intervals.
An ink interval is defined by two ink cursors: from and to corresponding to its stroke indexes.
The stroke index is the zero based index of the stroke of the object based on the sequence of pointer events composing the input of the recognizer.

Example:

```json
"range": [
{ "from": { "stroke": 0 }, "to": { "stroke": 105 } },
{ "from": { "stroke": 128 }, "to": { "stroke": 135 } }
],
```

- Text block object

Text recognition is performed by a new mixed math and text recognizer. So, a text block object may contain mixed math and text.

This new recognizer does not provide character nor word segmentation yet. So, `export.jiix.text.chars`, `export.jiix.text.words`and `export.jiix.text.structure`are ignored. 

Text block objects are segmented into lines and each line is segmented into spans. They have a bounding box and the following specific properties:

| Property | Description | Content | Note |
| --- | --- | --- | --- |
| label | Recognition result associated with this text block | A string | The label includes the line break if applicable. |
| lines | The array of lines that make up this text block. | A array of Line item blocks | Only present when export.jiix.text.lines is set to true. |

Example:

```json
{
"type": "Text",
"bounding-box": { ... },
"range": [ ... ],
"label": "The root of the quadratic equation\n$a x ^{2} + b x + c = 0$\nis given by the quadratic formula\n$x = \\frac{- b \\pm \\sqrt{\\Delta}}{2 a}$ where $\\bigtriangleup$ is the\ndiscriminant",
"lines": [ ... ]
}
```

The item of type Line has a bounding box and the following specific properties:

| Property | Description | Content | Note |
| --- | --- | --- | --- |
| label | Recognition result associated with this line | A string | The label of lines does not include the line break, which is added at block level if applicable. |
| spans | The array of spans that make up this line. | A array of Math and Text objects | See below example. |

Example:

```json
{
"type": "Line",
"bounding-box": { ... },
"range": [ ... ],
"label": "$x = \\frac{- b \\pm \\sqrt{\\Delta}}{2 a}$ where $\\bigtriangleup$ is the",
"spans": [ {
"type": "Math",
"bounding-box": { ... },
"range": [
{ "from": { "stroke": 52 }, "to": { "stroke": 56 } },
{ "from": { "stroke": 128 }, "to": { "stroke": 135 } }
],
"label": "x = \\frac{- b \\pm \\sqrt{\\Delta}}{2 a}"
}, {
"type": "Text",
"bounding-box": { ... },
"range": [
{ "from": { "stroke": 57 }, "to": { "stroke": 59 } }
],
"label": "where"
}, {
"type": "Math",
"bounding-box": { ... },
"range": [
{ "from": { "stroke": 60 }, "to": { "stroke": 60 } }
],
"label": "\\bigtriangleup"
}, {
"type": "Text",
"bounding-box": { ... },
"range": [
{ "from": { "stroke": 61 }, "to": { "stroke": 66 } }
],
"label": "is the"
} ]
}
```

Please note that `Math`spans give the LaTeX string without $ delimiters, while the surrounding line and block add $ delimiters around it. 
- Math block item

Math recognition is done by the “Math” recognizer and therefore only returns recognition results as a LaTeX strings.

Math block objects are segmented into lines and each line is segmented into spans like Text block objects. See the section above for more details about lines and spans.

| Property | Description | Content | Note |
| --- | --- | --- | --- |
| label | Recognition result as a LaTeX string associated with this math block | A string | |
| lines | The array of lines that make up this math block. | A array of Line item blocks | |

Example:

```json
{
"type": "Math",
"bounding-box": { ... },
"range": [ ... ],
"label": "$\\Delta = b ^{2} - 4 a c$",
"lines": [ ... ]
}
```

- Shape item block

A block of type Shape is similar to Shape block with optional range objects, when export.jiix.ranges configuration is enabled.

Example:

```json
{
"type": "Shape",
"bounding-box": { ... },
"range": [
{ "from": { "stroke": 106 }, "to": { "stroke": 109 } },
{ "from": { "stroke": 125 }, "to": { "stroke": 127 } }
],
"elements": [
{
"bounding-box": { ... },
"range": [
{ "from": { "stroke": 106 }, "to": { "stroke": 106 } }
],
"shape": {
"kind": "rectangle",
"primitives": [ ... ]
}
},
...
{
"bounding-box": { ... },
"range": [
{ "from": { "stroke": 126 }, "to": { "stroke": 127 } }
],
"shape": {
"kind": "curved arrow",
"primitives": [ ... ]
}
} ]
}
```

- Decoration item block

When decorations are detected in the content (requires “decoration” item in the recognizer.raw-content.classification.types array) a Decoration block will appear in the elements of the Main block.

There are 3 types of decoration: “Underline”, “StrikeThrough”, and “Grouping”:
A “Grouping” is a decoration that looks like text parentheses (, ), {, }, [, ], or | but groups other elements and may appear horizontally.

- When “decoration” is missing in the recognizer.raw-content.recognition.types array, the Decoration block contains at most one element for each type without further information.
- When “decoration” is present in the recognizer.raw-content.recognition.types array, the elements array lists each decoration separately with its type and, when type is “Underline” or “StrikeThrough”, the position of the fitted line segment as x1, y1, x2, y2.

Example:

```json
{
"type": "Decoration",
"bounding-box": { ... },
"range": [
{ "from": { "stroke": 174 }, "to": { "stroke": 178 } }
],
"elements": [ {
"type": "Grouping",
"bounding-box": { ... },
"range": [
{ "from": { "stroke": 174 }, "to": { "stroke": 174 } }
]
}, {
"type": "Grouping",
"bounding-box": { ... },
"range": [
{ "from": { "stroke": 175 }, "to": { "stroke": 175 } }
]
}, {
"type": "StrikeThrough",
"x1": 20.9924412,
"y1": 150.043182,
"x2": 47.2008286,
"y2": 150.043182,
"bounding-box": { ... },
"range": [
{ "from": { "stroke": 178 }, "to": { "stroke": 178 } }
]
}, {
"type": "Underline",
"x1": 69.8855133,
"y1": 74.2817154,
"x2": 120.709824,
"y2": 74.2817154,
"bounding-box": { ... },
"range": [
{ "from": { "stroke": 176 }, "to": { "stroke": 176 } }
]
}, {
"type": "Underline",
"x1": 18.0531464,
"y1": 88.0613861,
"x2": 68.8774567,
"y2": 88.0613861,
"bounding-box": { ... },
"range": [
{ "from": { "stroke": 177 }, "to": { "stroke": 177 } }
]
} ]
}
```

- Drawing item block

A block of type Drawing corresponds to a block of ink that was not classified as one of the other content types.
It contains the properties common to all blocks including optional range objects, when export.jiix.ranges configuration is enabled.

Example:

```json
{
"type": "Drawing",
"bounding-box": { ... },
"range": [
{ "from": { "stroke": 113 }, "to": { "stroke": 114 } },
{ "from": { "stroke": 120 }, "to": { "stroke": 120 } }
],
}
```

---

## Styling

*Source: https://developer.myscript.com/docs/interactive-ink/4.2/reference/styling/*

Styling reference 

This page list the most common styling properties supported by MyScript iink SDK.

If what you would to style is not listed here, please feel free to ask on our [on our developer forum](https://developer-support.myscript.com/support/discussions). 

## Style of the strokes

You can set the style associated with a pointer tool:
Supported properties are color, -myscript-pen-brush and -myscript-pen-width.

There are three additional options -myscript-pen-orientation-sensitivity, -myscript-pen-tilt-sensitivity and -myscript-pen-pressure-sensitivity to adjust the effect of orientation, tilt and pressure sensitivity on stroke rendering when such information is present in the input pointer events.

## Style of the fonts with a theme

MyScript iink SDK makes it easy to style content with a theme using CSS properties listed in this page.

In addition to these css styling properties, you can adjust its default configuration with different options presented here.

### Restrictions from CSS

The following restrictions apply:

- Only a limited subset of CSS properties is supported.
- Supported types are different from regular CSS types (e.g. type selectors like h1, p or div are not supported).
- The default unit is mm and properties provided with an explicit unit will be ignored.
- Keywords such as inherit, initial or unset are not supported.
- Universal selector (*) and combinators are not supported.
- Possibilities to express colors are constrained.

### Available classes and properties

### glyph type

MyScript iink SDK exposes the glyph type that allows you to specify fonts properties for all converted text glyphs:

| Property | Default value | Remarks |
| --- | --- | --- |
| font-family | “sans-serif” | |
| font-style | normal | |
| font-variant | normal | |
| font-weight | 300 | Only numerical values are supported. |

In addition, the following classes and properties are available that are specific to each content type:

### Diagram block

.diagram is the default class for items in a “Diagram” content block:

| Property | Default value | Remarks |
| --- | --- | --- |
| font-family | “sans-serif” | |
| font-style | normal | |
| font-variant | normal | |
| font-weight | 300 | Only numerical values are supported. |

### Math block

.math is the default class for items in a “Math” content block:

| Property | Default value | Remarks |
| --- | --- | --- |
| font-family | STIX Two Math | |
| font-style | normal | |
| font-variant | normal | |
| font-weight | 300 | Only numerical values are supported. |
| color | #000000FF | See possible values. |

.math-variable defines the style applied to the variables after ink conversion:

| Property | Default value | Remarks |
| --- | --- | --- |
| font-family | STIX Two Text | |
| font-style | italic | |
| font-variant | normal | |
| font-weight | 300 | Only numerical values are supported. |
| color | #000000FF | See possible values. |

.math-solved defines the style applied to the glyphs that are generated by the solver:

| Property | Default value | Remarks |
| --- | --- | --- |
| font-family | STIX Two Math | |
| font-style | normal | |
| font-weight | 300 | Only numerical values are supported. |
| color | #A8A8A8FF | See possible values. |

### Text block

.text is the default class for items in a “Text” content block:

| Property | Default value | Remarks |
| --- | --- | --- |
| font-family | “sans-serif” | |
| font-style | normal | |
| font-variant | normal | |
| font-weight | 300 | Only numerical values are supported. |
| font-size | None | In millimeters (model unit). |
| line-height | None | Multiplier of the font size. |

Note that iink computes the default line height and font size based on the device resolution instead of using a static css containing default values.
You can modify font-size and line-height values to adjust the guides spacing, but note that “Text” and “Text Document” guides spacings are not identical.

- For “Text” parts, the spacing of handwriting guides (if enabled) is given by font-size * line-height.
- For “Text Document” parts, the guides spacing considers the font-size and line-height product too. But some more computation adjusts the line gap.

In both cases, to avoid visual artifacts, you should change the editor theme before opening the part. 

For instance, the following CSS will correspond to a 13-millimeter spacing when the theme is set to a “Text” part. For a “Text Document” part, the example is still valid but the outcome might be slightly different.

```css
.text {
font-size: 10;
line-height: 1.3;
}
```

### Raw Content block

.raw-content is the default class for items in a “Raw Content” block:

| Property | Default value | Remarks |
| --- | --- | --- |
| font-family | “sans-serif” | |
| font-style | normal | |
| font-variant | normal | |
| font-weight | 300 | Only numerical values are supported. |

.raw-content-grid is the default class of the “Raw Content” block background grid, when the raw-content.line-pattern is grid:

| Property | Default value | Remarks |
| --- | --- | --- |
| color | #00000011 | See possible values. |

## Possible values

### Colors

Colors can be specified as rgb(), rgba(), hsl(), hsla(), #rgb, #rgba, #rrggbb, #rrggbbaa.

Named colors (black, red, etc.) are not supported.

### -myscript-pen-brush

- Possible values for built-in pen brushes are: Polyline, FountainPen, CalligraphicQuill, CalligraphicBrush, Qalam and FeltPen.
- In addition, you can implement additional brushes whose names must start with the prefix Extra-, such as Extra-Pencil in the Android demo example.
- Unknown values (including extra ones) fallback to FeltPen.

### -myscript-pen-orientation-sensitivity

This property values range from 0 to 1, with a default value of 0 meaning there is no effect and 1 meaning full sensitivity.

### -myscript-pen-tilt-sensitivity

This property values range from 0 to 1, with a default value of 0 meaning there is no effect and 1 meaning full sensitivity.

### -myscript-pen-pressure-sensitivity

This property values range from 0 to 1, with a default value of 0 meaning there is no effect and 1 meaning full sensitivity.

---

# Glossary | MyScript Developer

MyScript technology is built around a consistent set of concepts and conventions that can be expressed using a specific, non-ambiguous vocabulary. This page provides useful definitions that will help you easily understand and communicate these notions.

## [Configuration](#configuration)

**Configuration** is a way to fine-tune the default behavior of an SDK to meet one’s particular needs. With MyScript iink SDK, it is done at the [engine](#engine) or at [editor](#editor) level.

## [Configuration file](#configuration-file)

A **configuration file** (
```
*.conf
```
) is the textual representation of the parameters and [resources](#resource) that an [engine](#engine) shall consume to be able to recognize a particular type of content (a particular language, diagrams, maths, etc.).

## [Content block](#content-block)

With MyScript iink SDK, a **content block** corresponds to a semantic subdivision of the content, and may contain data and/or other blocks. For instance, a “Text Document” [part](#content-part) can be composed of “Text”, “Math”, “Diagram”, “Raw Content” and “Drawing” blocks. A “Math” part will only have a single block, hosting the math content itself.

## [Content package](#content-package)

With MyScript iink SDK, a **package** is a container storing ink and its interpretation as an ordered collection of [parts](#content-part). It can be saved as a file on the file system and later reloaded or exchanged between users.

## [Content part](#content-part)

With MyScript iink SDK, a **part** corresponds to a _standalone_ content unit that can be processed by the SDK. Each part has a specific type (“Text”, “Drawing”, “Diagram”, “Math”, “Raw Content” or “Text Document”). A part hosts a hierarchy of [blocks](#content-block).

## [Content type](#content-type)

The **type** of a piece of content identifies the semantic and structural rules that apply. For instance, “Text” and “Math” obey different layout rules, a “Drawing” is totally free from structural constraints, and a “Diagram” supports the concepts of nodes and edges.

MyScript iink SDK supports a certain number of content types out of the box.

## [Conversion](#conversion)

**Conversion** is the action of turning handwritten content into a [typeset](#typeset) equivalent.

## [Decoration](#decoration)

A **decoration** is a semantic marking of a portion of ink (typeset or not), usually by means of a [decoration gesture](#gesture). MyScript iink SDK supports several decoration types, such as underline, double-underline or circle.

## [Digital ink](#digital-ink)

**Digital ink** is the digital representation of the input made using a finger or a stylus on a surface. It corresponds to an ordered set of [strokes](#stroke). MyScript interprets digital ink to turn it into [Interactive Ink](https://developer.myscript.com/docs/interactive-ink/4.2/concepts/interactive-ink/)

## [Editor](#editor)

With MyScript iink SDK, an **editor** is the main entry point to act on interactive content. It is instantiated from an [
```
Engine
```
](#engine) object and manages input, import, export and the routing of rendering commands.

## [Engine](#engine)

An **engine** object represents the MyScript runtime environment. In MyScript iink SDK, it takes care of the recognition process and allows you to instantiate other important objects such as [packages](#content-package), [editors](#editor) and [renderers](#renderer).

## [Exchange format](#exchange-format)

The **exchange format** (
```
jiix
```
 extension) is a JSON representation of an interactive ink model and can be used to exchange information between MyScript iink SDK, the host application or at a wider scale. Readable and parseable, it is meant as a transitory step to support custom import and export capabilities.

See the [JIIX format reference](https://developer.myscript.com/docs/interactive-ink/4.2/reference/jiix/) for more information.

## [Gesture](#gesture)

A **gesture** corresponds to a sequence of one or several strokes that the engine will interpret as an intention to _edit_ or [_decorate_](#decoration) content. For example, scratching an ink or typeset word can be interpreted as an erasure, underlining another word as a way to decorate it to give it a particular semantic.

## [Glyph](#glyph)

A **glyph** is a graphic symbol that provides the look or shape for a character, i.e. its visual representation. For instance those glyphs represent the ‘h’ letter:

The MyScript engine examines glyphs and tries to determine, by its shape, loops, size, etc, which digital character they best match. Some glyphs are more alike than others and so the engine will choose the most likely match.

## [Ink item](#ink-item)

In the MyScript ecosystem, the **ink item** denomination encompasses the wide range of elements that can be manipulated by the model, whether they correspond to raw/processed [digital ink](#digital-ink) or [typeset](#typeset) content.

## [Inking](#inking)

**Inking** specifically refers to the rendering of ink [strokes](#stroke). It can be obtained by different rendering technologies and algorithms and is usually based on stroke information such as individual point coordinates, associated pressure and time information, as well as styling considerations like stroke width and color.

## [Interactive ink (iink)](#interactive-ink-iink)

**MyScript interactive ink technology** relies on interpretation of digital ink to make it able to obey the same kind of manipulation rules that people have come to expect from other types of digital content, making it usable in a productive environment.

## [Raw content](#raw-content)

**Raw content** corresponds to content which semantic structure is unknown by MyScript iink SDK, in that it was not explicitly segmented according to supported [content types](#content-type). For example, free notes retrieved from a digital pen&paper solution may mix text, math, doodles or any other content without explicit structure.

MyScript iink SDK manages such content via the “Raw Content” [content part](#content-part) and provides some analysis capabilities such as text block extraction that can let an integrator build an ink search engine.

## [Renderer](#renderer)

A **renderer** is a software component that issues rendering commands to render content, knowing which areas of the model need to be refreshed, as well as parameters such as zoom factor or view offset.

## [Resource](#resource)

A **resource** corresponds to a character or linguistic piece of knowledge that can be consumed by a MyScript [engine](#engine) to be able to recognize a particular type of content.

## [Stroke](#stroke)

A **stroke** is defined as the trajectory of a finger or stylus on a surface, from the moment it touches the writing area until it is lifted again. The ‘hello’ word below is written with 4 strokes:

A stroke is represented as a time-ordered sequence of 2D points (
```
x
```
, 
```
y
```
, 
```
t
```
), where 
```
x
```
 and 
```
y
```
 are the coordinates and 
```
t
```
 the [timestamp](#timestamp).

## [Stroker](#stroker)

A **stroker** is a software component that generates the rendering of a [stroke](#stroke). Depending on styling options that are chosen, strokes may look different (for instance, as drawn by a bullet pen or a calligraphy brush).

## [Style sheet](#style-sheet)

A **style sheet** is the declarative definition of the look & feel of various ink items ([typeset](#typeset) or not). It allows you for example to set the color of the ink or the background color to apply when an item is highlighted. MyScript iink SDK relies on [a subset of CSS with a few specificities](https://developer.myscript.com/docs/interactive-ink/4.2/reference/styling/).

## [Timestamp](#timestamp)

A **timestamp** is a value that _precisely_ identified the moment an element was captured or generated. By convention, it corresponds to the time in milliseconds elapsed since January, 1<sup>st</sup> 1970. It is particularly important in an interactive context, where it enables the engine to process the input to detect editing or decoration gestures.

## [Typeset](#typeset)

**Typeset** is the result of [conversion](#conversion) of [digital ink](#digital-ink): a clean representation of the digital content based on fonts and clean vector shapes.

