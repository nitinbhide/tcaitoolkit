---
name: thinking-craftsman-skill
description: This skill defines the coding and code review guidelines based on principles documented by Nitin Bhide (Thinking Craftsman). These guidelines are independant of programming language or technology stack.
metadata: 
	author: Nitin Bhide (nitinbhide@thinkingcraftsman.in)
	version : "1.0"
license: Apache 2.0
allowed-tools : bash git sourcemonitor cpd hg svn 
user-invocable: true
disable-model-invocation: true
---

# Thinking Craftsman Coding Skill

[Thinking Craftsman](http://thinkingcraftsman.in) coding skill defines the coding concepts and principles that apply across broad range of technologies and programming languages. 
## When to Invoke

- **Invoke directly when:** the user asks for a "thinking craftsman" review of a specific change, file, or PR.
- **Invoke via:** `/tcreview` (single-perspective review) 
- Use the template defined in `references\templates.md` as per the task type
- Use the language specific information from `references\<language>.md` e.g. `references\python.md` for information specific to python language, C++ use `references\cpp.md`
## When and How to Apply 
Apply these guidelines during agentic code generation and during code review. Guidelines that are applicable only at review are tagged with `Review Only`

There are two categories of guidelines. 
- Guidelines that are applicable at entire file scope or at entire class scope. Typically these are at the start of the source code file.
- Guidelines that are applicable at individual function level. These are applicable to global scope functions or class member functions
### Guidelines at File or Class Level

- `Review Only` **Check for dead code or redundant code.** 
	- Dead code is the code that exists in source files but is not called from any where. 
	- It may be private function not called from many public member function. Or a variable declared but not used. 
	- In general use Compiler features/warnings to detect these.
- `Review Only` **Detect code duplication**
	- Detect /check if there is exact duplicate code in multiple functions. 
	- Duplication can be in the same file or across multiple files. 
	- In general use tools like CPD (Copy Paste Detector) in detecting the exact duplicates. 
	- Highlight the code duplication in different files as potential design issue. 
- **Minimize /Avoid Mutable Global State**
	- The global variables, class static variables, fil level or namespace level static variables, classes that follow singleton patterns are global state. 
	- Avoid adding global state to the source . 
	- Immutable global state is ok. 
	- However, minimize the mutable global state
- **Minimize the dependencies on external files, classes**
	- The includes or imports or using statements at anywhere in the source file indicate dependency on external classes or methods or files. 
	- Review critically if the new dependency is added in the file. 
	- Avoid adding new dependencies while modifying existing file 
	- If a new dependency is required, explain why
	- When generating new file minimize the number of external dependencies.
	- Remember using 'dependency injection' is still adding dependency but at runtime. Prefer compile time dependency over runtime dependency
	- Avoid circular dependencies (imports or includes )
- **The class should based on "Tell" principle and avoid 'asking' for internal state**
	- The class should follow 'Tell, Dont Ask' principle. The class methods should be about 'telling the class to do some operation on its internal state'. 
	- Minimize the methods that query the internal state of the class (get methods) 
	- Minimize the methods that just directly change the member variable of class (set methods)
	- The class should NEVER return pointer or reference to a internal collection (e.g. vector, List, map) from any member method. 
- **The class should never violate "Liskov Substitution Principle (LSP)"**
	- If the current class is derived from another class (base class), analyze the assumptions of the base class. Then check if any method of the derived class is violating the assumptions of the base class. Identify and highlight such methods. 
	- Wherever function names are same for base class and derived class, assume that derived class function is overriding the base class function.
	- Analyze the assumptions of the base class method. Analyze the assumptions of the derived class method. Preconditions of deriver class method MUST be lenient than the base class method. Post conditions of the derived class method must be stricter than the base class method. 
	- If you are not sure about strictness about the pre or post conditions, ask user to verify the conditions. 
	- Do not generate any methods that violates LSP during the code generation
	- 
- Respect module boundaries and layering
- Do not move files unless explicitly instructed
 - Keep configuration separate from runtime logic
### Guideline at individual function level
-  Keep functions small and single-purpose
- **Complexity of function (lines of code, cyclomatic complexity and block depth)**
	- Maximum size of the function should be 25 lines. Entire function should be visible without doing any page up/down operation
	- The cyclomatic complexity of the function should be less 10
	- Block depth of the function should be less than 6
- **Check Assumptions and the Side Effects**
	- Prefer explicit code over clever or implicit behavior
	- Do not make implicit assumptions about the input of the function and output of the called functions.
	- Avoid hard code values for array bounds, flags, etc
	- Use annotations (e.g. NotNull, Nullable), standard decorators to validate the assumptions
	- In case, annotation is not available, Use assertions to validate the assumptions about the inputs and outputs. 
	- Check if there are any unintended side effects for given code. For example, assignment to a variable will overwrite the original value. If the variable is object instance or a pointer, it may result in dangling objects.
- **Do not violate Law of Demeter**
	 - It is ok to use Builder Pattern or jquery style function chaining. 
	 - Avoid digging into the internals of a class.
	 - Avoid chaining of 'get' methods.
 - **Handle the errors and exceptions. Do not suppress them**
	 - Prefer unchecked exceptions over checked exceptions
	 - Do not swallow exceptions silently
		 - Do not create empty catch blocks. 
		 - The catch blocks that just print or log the errors/exceptions are empty catch blocks
	 - Do not catch base exception for your programming language. The 'base exception class' in the base class of all exceptions in the given programming language. Catch specific types of exceptions. For example, in python do not catch 'Exception'
	 - Do not catch '...' exceptions
	 - Catch the exceptions as late as possible. 
	 - Avoid catching the exceptions in private and protected methods. Catch the exceptions in public methods.
	 - Avoid catching exceptions in low level modules/packages. Catch the exceptions in high level modules/packages.
 - **Do not create easy to misuse function**
   Functions and classes must be 'easy to use' but 'hard to misuse'. Mutability of class increases possibility of misuse
	 - Minimize 'set/get' methods
	 - Implicit assumptions can make a function easy to misuse
 - **Function should Fail Fast**
	 - Return errors quickly
	 - Assert the assumptions that function has, if any
	 - Throw the exceptions as early as possible in the program logic
	
## Additional Guidelines for Code Review
- Diff Review
	- Identify the differences between two given revisions or latest revision of branch and master/main branch or two different branches.  
	- Generate a 'diff view' of changes between these revisions. 
	- Use 'unified diff' format for generating the 'diff views'
	- Use the information in 'version control skill' to generate the diff or 'diff view'
	- Analyze the diff view using the File level and function level code review guidelines defined in this file.
	- "New dependency" added is important check in 'diff review'
- Periodically do a full file review applying all the guidelines.
## Rules for reviewing code
 - Read the spec or task description, related code comment before analyzing /reviewing code
 - If you're uncertain about something, say so and suggest investigation rather than guessing
## Rules for generating code
- Read the spec or task description and related existing code and  comments before  generating new code
- Write the Tests Before writing the code. 
	- Generate the unit tests as per the project unit test guidelines
	- If there are no unit test guidelines, then generate the test descriptions and not code. Use the template "Test Description template" defined in the ```references\Templates``` for generating test descriptions. 
- If you're uncertain about something, say so and suggest investigation rather than guessing
