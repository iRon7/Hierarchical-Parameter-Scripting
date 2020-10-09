#Requires -Modules @{ModuleName="Pester"; ModuleVersion="5.0.0"}

Import-Module .\ParameterFunctions.psm1

Describe 'Test parameters' {
    
    BeforeAll {
    
        function Compare-Parameters ([String]$Function, [String]$WithFunction, [String[]]$WithSyntax) {
            function getSyntax ([String]$Function) {
                $Section = $Null
                foreach ($Line in ((Get-Help $Function | Out-String) -Split '[\r\n]+')) {
                    switch -Regex -CaseSensitive ($Line) {
                        '^[A-Z]+$' { $Section = $Line }
                        '^[\s]+[\S]+' { If ($Section -eq 'SYNTAX') { $Line -Replace ('^\s*' + $Function.ToString() + '\s') } }
                    }
                }
            }
            $Syntax = getSyntax $Function
            if ($WithFunction) { $WithSyntax = getSyntax $WithFunction } else { $WithFunction = '<Parameters>' }
            
            $Compare = Compare-Object $Syntax $WithSyntax
          
            if ($Compare) { 
                Compare-Object -IncludeEqual $Syntax $WithSyntax | Foreach-Object {
                    [pscustomobject]@{
                        Parameter = $_.InputObject
                        Function = $_.SideIndicator =
                            if ($_.SideIndicator -eq '<=') { $Function }
                            elseif ($_.SideIndicator -eq '=>') { $WithFunction }
                            else { $Function + '/' + $WithFunction }
                    }
                } | Out-String
            }
        }
    }
    
    Context 'Parameter Only' {
    
        it 'Single optional parameter' {
        
            function CMO {
                [CmdletBinding()] param(
                    [string]$Param
                )
            }

            function FMO {
                [CmdletBinding()] param()
                DynamicParam {
                    New-Param 0 ([string]) Param -Default 'DefaultValue'
                }
                Process {
                    write-host $PSBoundParameters['Param'] # Default doesn't work yet
                }
            }
            
            Compare-Parameters FMO CMO | Should -BeNull
        }
        
        it 'Single madatory parameter' {
        
            function CMO {
                [CmdletBinding()] param(
                    [Parameter(Mandatory = $True)]
                    [string]$Param
                )
            }

            function FMO {
                [CmdletBinding()] param()
                DynamicParam {
                    New-Param 0 ([string]) Param -Mandatory
                }
            }
            
            Compare-Parameters FMO CMO | Should -BeNull
        }
    }
    
    Context 'Single set' {
    
        it 'Two opional parameters' {
        
            function CMO {
                [CmdletBinding()] param(
                    [string]$Param1,
                    [string]$Param2
                )
            }
            
            function FMO {
                [CmdletBinding()] param()
                DynamicParam {
                    New-ParamSet @(
                        New-Param 0 ([string]) Param1
                        New-Param 1 ([string]) Param2
                    )
                }
            }
            
            Compare-Parameters FMO CMO | Should -BeNull
        }

        it 'Two Mandatory parameters' {
        
            function CMO {
                [CmdletBinding()] param(
                    [Parameter(Mandatory = $True)][string]$Param1,
                    [Parameter(Mandatory = $True)][string]$Param2
                )
            }

            function FMO {
                [CmdletBinding()] param()
                DynamicParam {
                    New-ParamSet @(
                        New-Param 0 ([string]) Param1 -Mandatory
                        New-Param 1 ([string]) Param2 -Mandatory
                    )
                }
            }
        }

        it 'One optional, one mandatory parameters' {
        
            function CMO {
                [CmdletBinding()] param(
                    [Parameter(Mandatory = $False)][string]$Param1,
                    [Parameter(Mandatory = $True) ][string]$Param2
                )
            }

            function FMO {
                [CmdletBinding()] param()
                DynamicParam {
                    New-ParamSet @(
                        New-Param 0 ([string]) Param1
                        New-Param 1 ([string]) Param2 -Mandatory
                    )
                }
            }
        }

    }

    Context 'Multipe (hierarchical) sets' {
    
        it 'Two sets with opional parameters' {
        
            function CMO {
                [CmdletBinding()] param(
                    [Parameter(ParameterSetName = 'Set1')]
                    [string]$Param1,
                    
                    [Parameter(ParameterSetName = 'Set1')]
                    [string]$Param2,

                    [Parameter(ParameterSetName = 'Set2')]
                    [string]$Param3,
                    
                    [Parameter(ParameterSetName = 'Set2')]
                    [string]$Param4
                )
            }

            function FMO {
                [CmdletBinding()] param()
                DynamicParam {
                    New-ParamSet @(
                        New-ParamSet @(
                            New-Param ([string]) Param1
                            New-Param ([string]) Param2
                        )
                        New-ParamSet @(
                            New-Param ([string]) Param3
                            New-Param ([string]) Param4
                        )
                    )
                }
            }
            
            Compare-Parameters FMO CMO | Should -BeNull
        }

        it 'Two sets with mandatory parameters' {
        
            function CMO {
                [CmdletBinding()] param(
                    [Parameter(ParameterSetName = 'Set1', Mandatory = $True)]
                    [string]$Param1,
                    
                    [Parameter(ParameterSetName = 'Set1', Mandatory = $True)]
                    [string]$Param2,

                    [Parameter(ParameterSetName = 'Set2', Mandatory = $True)]
                    [string]$Param3,
                    
                    [Parameter(ParameterSetName = 'Set2', Mandatory = $True)]
                    [string]$Param4
                )
            }

            function FMO {
                [CmdletBinding()] param()
                DynamicParam {
                    New-ParamSet @(
                        New-ParamSet @(
                            New-Param ([string]) Param1 -Mandatory
                            New-Param ([string]) Param2 -Mandatory
                        )
                        New-ParamSet @(
                            New-Param ([string]) Param3 -Mandatory
                            New-Param ([string]) Param4 -Mandatory
                        )
                    )
                }
            }
            
            Compare-Parameters FMO CMO | Should -BeNull
        }

        it 'Two sets with positioned opional parameters' {
        
            function CMO {
                [CmdletBinding(DefaultParameterSetName = 'Set1')] param(
                    [Parameter(Position = 0, ParameterSetName = 'Set1')]
                    [string]$Param1,
                    
                    [Parameter(Position = 1, ParameterSetName = 'Set1')]
                    [string]$Param2,

                    [Parameter(Position = 0, ParameterSetName = 'Set2')]
                    [string]$Param3,
                    
                    [Parameter(Position = 1, ParameterSetName = 'Set2')]
                    [string]$Param4
                )
            }

            function FMO {
                [CmdletBinding()] param()
                DynamicParam {
                    New-ParamSet @(
                        New-ParamSet @(
                            New-Param 0 ([string]) Param1
                            New-Param 1 ([string]) Param2
                        )
                        New-ParamSet @(
                            New-Param 0 ([string]) Param3
                            New-Param 1 ([string]) Param4
                        )
                    )
                }
            }
            
            Compare-Parameters FMO CMO | Should -BeNull
        }
        
        it 'Two sets with positioned mandatory parameters' {
        
            function CMO {
                [CmdletBinding()] param(
                    [Parameter(Position = 0, ParameterSetName = 'Set1', Mandatory = $True)]
                    [string]$Param1,
                    
                    [Parameter(Position = 1, ParameterSetName = 'Set1', Mandatory = $True)]
                    [string]$Param2,

                    [Parameter(Position = 0, ParameterSetName = 'Set2', Mandatory = $True)]
                    [string]$Param3,
                    
                    [Parameter(Position = 1, ParameterSetName = 'Set2', Mandatory = $True)]
                    [string]$Param4
                )
            }

            function FMO {
                [CmdletBinding()] param()
                DynamicParam {
                    New-ParamSet @(
                        New-ParamSet @(
                            New-Param 0 ([string]) Param1 -Mandatory
                            New-Param 1 ([string]) Param2 -Mandatory
                        )
                        New-ParamSet @(
                            New-Param 0 ([string]) Param3 -Mandatory
                            New-Param 1 ([string]) Param4 -Mandatory
                        )
                    )
                }
            }
            
            Compare-Parameters FMO CMO | Should -BeNull
        }

        it 'One mandatory parameter with a set of two optional parameters' {
        
            function CMO {
                [CmdletBinding()] param(
                    [Parameter(Position = 0, ParameterSetName = 'Set1', Mandatory = $True)]
                    [string]$Param1,
                    
                    [Parameter(ParameterSetName = 'Set1')]
                    [string]$Param2,

                    [Parameter(ParameterSetName = 'Set1')]
                    [string]$Param3
                )
            }

            function FMO {
                [CmdletBinding()] param()
                DynamicParam {
                    New-ParamSet @(
                        New-Param 0 ([string]) Param1 -Mandatory
                        New-ParamSet @(
                            New-Param ([string]) Param2
                            New-Param ([string]) Param3
                        )
                    )
                }
            }
            
            Compare-Parameters FMO CMO | Should -BeNull
        }

        it 'One mandatory parameter with a set of two mandatory parameters' {
        
            function CMO {
                [CmdletBinding()] param(
                    [Parameter(Position = 0, ParameterSetName = 'Set1', Mandatory = $True)]
                    [string]$Param1,
                    
                    [Parameter(ParameterSetName = 'Set1', Mandatory = $True)]
                    [string]$Param2,

                    [Parameter(ParameterSetName = 'Set1', Mandatory = $True)]
                    [string]$Param3
                )
            }

            function FMO {
                [CmdletBinding()] param()
                DynamicParam {
                    New-ParamSet @(
                        New-Param 0 ([string]) Param1 -Mandatory
                        New-ParamSet @(
                            New-Param ([string]) Param2 -Mandatory
                            New-Param ([string]) Param3 -Mandatory
                        )
                    )
                }
            }
            
            Compare-Parameters FMO CMO | Should -BeNull
        }

        it 'One mandatory parameter with two mutually exclusive parameters' {
        
            function CMO {
                [CmdletBinding()] param(
                    [Parameter(Position = 0, ParameterSetName = 'Set1', Mandatory = $True)]
                    [Parameter(Position = 0, ParameterSetName = 'Set2', Mandatory = $True)]
                    [string]$Param1,
                    
                    [Parameter(Position = 1, ParameterSetName = 'Set1', Mandatory = $True)]
                    [string]$Param2,

                    [Parameter(Position = 1, ParameterSetName = 'Set2', Mandatory = $True)]
                    [string]$Param3
                )
            }

            function FMO {
                [CmdletBinding()] param()
                DynamicParam {
                    New-ParamSet @(
                        New-Param 0 ([string]) Param1 -Mandatory
                        New-ParamSet @(
                            New-Param 1 ([string]) Param2 -Mandatory
                        )
                        New-ParamSet @(
                            New-Param 1 ([string]) Param3 -Mandatory
                        )
                    )
                }
            }
            
            Compare-Parameters FMO CMO | Should -BeNull
        }

        it 'an optional parameter could require some mandatory/optional subparameters.' {
        
            function CMO {
                [CmdletBinding()] param(
                    [Parameter(ParameterSetName = 'Set1', Mandatory = $True)]
                    [string]$Param2,

                    [Parameter(ParameterSetName = 'Set1')]
                    [string]$Param3,

                    [Parameter(ParameterSetName = 'Set1')]
                    [Parameter(ParameterSetName = 'Set2')]
                    [string]$Param1
                    
                )
            }

            function FMO {
                [CmdletBinding()] param()
                DynamicParam {
                    New-ParamSet @(
                        New-Param ([string]) Param1
                        New-ParamSet @(
                            New-Param ([string]) Param2 -Mandatory
                            New-Param ([string]) Param3
                        )
                    )
                }
            }
            
            Compare-Parameters FMO CMO | Should -BeNull
        }
    }

    Context 'Syntax Notation' { # https://docs.informatica.com/data-integration/powercenter/10-1/command-reference/using-the-command-line-programs/syntax-notation.html
    
        it '-x' { # Option placed before a argument. This designates the parameter you enter.
        
            function CMO {
                [CmdletBinding()] param(
                    [switch]$x
                )
            }

            function FMO {
                [CmdletBinding()] param()
                DynamicParam {
                    New-Param 0 ([switch]) x
                }
            }
            
            # Compare-Parameters FMO CMO | Should -BeNull
       
        }
        
        it '<x>' { # Required option. If you omit a required option, the command line program returns an error message.
        
            function CMO {
                [CmdletBinding()] param(
                    [Parameter(Mandatory = $True)]
                    [string]$x
                )
            }

            function FMO {
                [CmdletBinding()] param()
                DynamicParam {
                    New-Param 0 ([string]) x -Mandatory
                }
            }
            
            Compare-Parameters FMO CMO | Should -BeNull
       
        }

        it '<x|y>' { # Select between required options. For the command to run, you must select from the listed options. If you omit a required option, the command line program returns an error message.
        
            function CMO {
                [CmdletBinding()] param(
                    [Parameter(ParameterSetName = 'x', Mandatory = $True)]
                    [string]$x,
                    
                    [Parameter(ParameterSetName = 'y', Mandatory = $True)]
                    [string]$y
                )
            }

            function FMO {
                [CmdletBinding()] param()
                DynamicParam {
                    New-ParamSet @(
                        New-ParamSet @(
                            New-Param ([string]) x -Mandatory
                        )
                        New-ParamSet @(
                            New-Param ([string]) y -Mandatory
                        )
                    )
                }
            }
            
            Compare-Parameters FMO CMO | Should -BeNull
        }
        
        it '[x]' { # Optional parameter. The command runs whether or not you enter optional parameters.
        
            function CMO {
                [CmdletBinding()] param(
                    [string]$x
                )
            }

            function FMO {
                [CmdletBinding()] param()
                DynamicParam {
                    New-Param 0 ([string]) x
                }
            }
            
            Compare-Parameters FMO CMO | Should -BeNull
       
        }

        it '[x|y]' { # Select between optional parameters.
        
            function CMO {
                [CmdletBinding()] param(
                    [string]$x,
                    [string]$y
                )
            }
            
            function FMO {
                [CmdletBinding()] param()
                DynamicParam {
                    New-ParamSet @(
                        New-Param 0 ([string]) x
                        New-Param 1 ([string]) y
                    )
                }
            }
            
            Compare-Parameters FMO CMO | Should -BeNull
        }
        
    }

    Context 'Use cases' {
    
        it 'Multiple shapes' {
        
            function CMO {
                [CmdletBinding()] param(
                    [Parameter(Position = 0, ParameterSetName = 'Circle', Mandatory = $True)]
                    [int]$Radius,
                    
                    [Parameter(Position = 0, ParameterSetName = 'Square', Mandatory = $True)]
                    [int]$Width,

                    [Parameter(Position = 1, ParameterSetName = 'Square', Mandatory = $True)]
                    [int]$Height,

                    [Parameter(Position = 0, ParameterSetName = 'Triangle', Mandatory = $True)]
                    [int]$Side1,

                    [Parameter(Position = 1, ParameterSetName = 'Triangle', Mandatory = $True)]
                    [int]$Side2,

                    [Parameter(Position = 2, ParameterSetName = 'Triangle', Mandatory = $True)]
                    [int]$Side3
                )
            }
            
            function FMO {
                [CmdletBinding()] param()
                DynamicParam {
                    New-ParamSet @(
                        New-ParamSet @(
                            New-Param 0 ([int]) Radius -Mandatory
                        )
                        New-ParamSet @(
                            New-Param 0 ([int]) Width  -Mandatory
                            New-Param 1 ([int]) Height -Mandatory
                        )
                        New-ParamSet @(
                            New-Param 0 ([int]) Side1 -Mandatory
                            New-Param 1 ([int]) Side2 -Mandatory
                            New-Param 2 ([int]) Side3 -Mandatory
                        )
                    )
                }
            }
            
            Compare-Parameters FMO CMO | Should -BeNull
        }
        
        it 'Circle with mutually exclusive RGB/HSL color' {
        
            function CMO {
                [CmdletBinding()] param(
                    [Parameter(Position = 0, ParameterSetName = 'CircleRGB', Mandatory = $True)]
                    [Parameter(Position = 0, ParameterSetName = 'CircleHSL', Mandatory = $True)]
                    [int]$Radius,
                    
                    [Parameter(ParameterSetName = 'CircleRGB')]
                    [int]$Red,

                    [Parameter(ParameterSetName = 'CircleRGB')]
                    [int]$Green,

                    [Parameter(ParameterSetName = 'CircleRGB')]
                    [int]$Blue,
                    
                    [Parameter(ParameterSetName = 'CircleHSL')]
                    [int]$Hue,

                    [Parameter(ParameterSetName = 'CircleHSL')]
                    [int]$Sat,

                    [Parameter(ParameterSetName = 'CircleHSL')]
                    [int]$Lum
                )
            }

            function FMO {
                [CmdletBinding()] param()
                DynamicParam {
                    New-ParamSet @(
                        New-Param 0 ([int]) Radius -Mandatory
                        New-ParamSet @(
                            New-ParamSet @(
                                New-Param ([int]) Red
                                New-Param ([int]) Green
                                New-Param ([int]) Blue
                            )
                            New-ParamSet @(
                                New-Param ([int]) Hue
                                New-Param ([int]) Sat
                                New-Param ([int]) Lum
                            )
                        )
                    )
                }
            }

            Compare-Parameters FMO CMO | Should -BeNull
        }
  
        it 'multiple shapes with mutually exclusive RGB/HSL color' {
            function CMO {
                [CmdletBinding()] param(
                    [Parameter(Position = 0, ParameterSetName = 'CircleRGB', Mandatory = $True)]
                    [Parameter(Position = 0, ParameterSetName = 'CircleHSL', Mandatory = $True)]
                    [int]$Radius,
                    
                    [Parameter(Position = 0, ParameterSetName = 'SquareRGB', Mandatory = $True)]
                    [Parameter(Position = 0, ParameterSetName = 'SquareHSL', Mandatory = $True)]
                    [int]$Width,

                    [Parameter(Position = 1, ParameterSetName = 'SquareRGB', Mandatory = $True)]
                    [Parameter(Position = 1, ParameterSetName = 'SquareHSL', Mandatory = $True)]
                    [int]$Height,

                    [Parameter(Position = 0, ParameterSetName = 'TriangleRGB', Mandatory = $True)]
                    [Parameter(Position = 0, ParameterSetName = 'TriangleHSL', Mandatory = $True)]
                    [int]$Side1,

                    [Parameter(Position = 1, ParameterSetName = 'TriangleRGB', Mandatory = $True)]
                    [Parameter(Position = 1, ParameterSetName = 'TriangleHSL', Mandatory = $True)]
                    [int]$Side2,

                    [Parameter(Position = 2, ParameterSetName = 'TriangleRGB', Mandatory = $True)]
                    [Parameter(Position = 2, ParameterSetName = 'TriangleHSL', Mandatory = $True)]
                    [int]$Side3,
                    
                    [Parameter(ParameterSetName = 'CircleRGB')]
                    [Parameter(ParameterSetName = 'SquareRGB')]
                    [Parameter(ParameterSetName = 'TriangleRGB')]
                    [int]$Red,

                    [Parameter(ParameterSetName = 'CircleRGB')]
                    [Parameter(ParameterSetName = 'SquareRGB')]
                    [Parameter(ParameterSetName = 'TriangleRGB')]
                    [int]$Green,

                    [Parameter(ParameterSetName = 'CircleRGB')]
                    [Parameter(ParameterSetName = 'SquareRGB')]
                    [Parameter(ParameterSetName = 'TriangleRGB')]
                    [int]$Blue,

                    [Parameter(ParameterSetName = 'CircleHSL')]
                    [Parameter(ParameterSetName = 'SquareHSL')]
                    [Parameter(ParameterSetName = 'TriangleHSL')]
                    [int]$Hue,

                    [Parameter(ParameterSetName = 'CircleHSL')]
                    [Parameter(ParameterSetName = 'SquareHSL')]
                    [Parameter(ParameterSetName = 'TriangleHSL')]
                    [int]$Sat,

                    [Parameter(ParameterSetName = 'CircleHSL')]
                    [Parameter(ParameterSetName = 'SquareHSL')]
                    [Parameter(ParameterSetName = 'TriangleHSL')]
                    [int]$Lum
                )

                function FMO {
                    [CmdletBinding()] param()
                    DynamicParam {
                        New-ParamSet @(
                            New-ParamSet @(
                                New-Param 0 ([int]) Radius -Mandatory
                                New-ParamSet @(
                                    New-ParamSet @(
                                        New-Param ([int]) Red
                                        New-Param ([int]) Green
                                        New-Param ([int]) Blue
                                    )
                                    New-ParamSet @(
                                        New-Param ([int]) Hue
                                        New-Param ([int]) Sat
                                        New-Param ([int]) Lum
                                    )
                                )
                            )
                            New-ParamSet @(
                                New-Param 0 ([int]) Width  -Mandatory
                                New-Param 1 ([int]) Height -Mandatory
                                New-ParamSet @(
                                    New-ParamSet @(
                                        New-Param ([int]) Red
                                        New-Param ([int]) Green
                                        New-Param ([int]) Blue
                                    )
                                    New-ParamSet @(
                                        New-Param ([int]) Hue
                                        New-Param ([int]) Sat
                                        New-Param ([int]) Lum
                                    )
                                )
                            )
                            New-ParamSet @(
                                New-Param 0 ([int]) Side1 -Mandatory
                                New-Param 1 ([int]) Side2 -Mandatory
                                New-Param 2 ([int]) Side3 -Mandatory
                                New-ParamSet @(
                                    New-ParamSet @(
                                        New-Param ([int]) Red
                                        New-Param ([int]) Green
                                        New-Param ([int]) Blue
                                    )
                                    New-ParamSet @(
                                        New-Param ([int]) Hue
                                        New-Param ([int]) Sat
                                        New-Param ([int]) Lum
                                    )
                                )
                            )
                        )
                    }
                }
                
                Compare-Parameters FMO CMO | Should -BeNull

                function FMO {
                    [CmdletBinding()] param()
                    DynamicParam {
                        $Color = New-ParamSet @(
                            New-ParamSet @(
                                New-Param ([int]) Red
                                New-Param ([int]) Green
                                New-Param ([int]) Blue
                            )
                            New-ParamSet @(
                                New-Param ([int]) Hue
                                New-Param ([int]) Sat
                                New-Param ([int]) Lum
                            )
                        )
                        New-ParamSet @(
                            New-ParamSet @(
                                New-Param 0 ([int]) Radius -Mandatory
                                $Color
                            )
                            New-ParamSet @(
                                New-Param 0 ([int]) Width  -Mandatory
                                New-Param 1 ([int]) Height -Mandatory
                                $Color
                            )
                            New-ParamSet @(
                                New-Param 0 ([int]) Side1 -Mandatory
                                New-Param 1 ([int]) Side2 -Mandatory
                                New-Param 2 ([int]) Side3 -Mandatory
                                $Color
                            )
                        )
                    }
                }

                Compare-Parameters FMO CMO | Should -BeNull
            }
        }

        it 'multiple shapes with mutually exclusive RGB/HSL color' {
            function CMO {
                [CmdletBinding()] param(
                    [Parameter(Position = 0, ParameterSetName = 'CircleTransparencyRGB', Mandatory = $True)]
                    [Parameter(Position = 0, ParameterSetName = 'CircleTransparencyHSL', Mandatory = $True)]
                    [Parameter(Position = 0, ParameterSetName = 'CircleOpacityRGB', Mandatory = $True)]
                    [Parameter(Position = 0, ParameterSetName = 'CircleOpacityHSL', Mandatory = $True)]
                    [int]$Radius,
                    
                    [Parameter(Position = 0, ParameterSetName = 'SquareTransparencyRGB', Mandatory = $True)]
                    [Parameter(Position = 0, ParameterSetName = 'SquareTransparencyHSL', Mandatory = $True)]
                    [Parameter(Position = 0, ParameterSetName = 'SquareOpacityRGB', Mandatory = $True)]
                    [Parameter(Position = 0, ParameterSetName = 'SquareOpacityHSL', Mandatory = $True)]
                    [int]$Width,

                    [Parameter(Position = 1, ParameterSetName = 'SquareTransparencyRGB', Mandatory = $True)]
                    [Parameter(Position = 1, ParameterSetName = 'SquareTransparencyHSL', Mandatory = $True)]
                    [Parameter(Position = 1, ParameterSetName = 'SquareOpacityRGB', Mandatory = $True)]
                    [Parameter(Position = 1, ParameterSetName = 'SquareOpacityHSL', Mandatory = $True)]
                    [int]$Height,

                    [Parameter(Position = 0, ParameterSetName = 'TriangleTransparencyRGB', Mandatory = $True)]
                    [Parameter(Position = 0, ParameterSetName = 'TriangleTransparencyHSL', Mandatory = $True)]
                    [Parameter(Position = 0, ParameterSetName = 'TriangleOpacityRGB', Mandatory = $True)]
                    [Parameter(Position = 0, ParameterSetName = 'TriangleOpacityHSL', Mandatory = $True)]
                    [int]$Side1,

                    [Parameter(Position = 1, ParameterSetName = 'TriangleTransparencyRGB', Mandatory = $True)]
                    [Parameter(Position = 1, ParameterSetName = 'TriangleTransparencyHSL', Mandatory = $True)]
                    [Parameter(Position = 1, ParameterSetName = 'TriangleOpacityRGB', Mandatory = $True)]
                    [Parameter(Position = 1, ParameterSetName = 'TriangleOpacityHSL', Mandatory = $True)]
                    [int]$Side2,

                    [Parameter(Position = 2, ParameterSetName = 'TriangleTransparencyRGB', Mandatory = $True)]
                    [Parameter(Position = 2, ParameterSetName = 'TriangleTransparencyHSL', Mandatory = $True)]
                    [Parameter(Position = 2, ParameterSetName = 'TriangleOpacityRGB', Mandatory = $True)]
                    [Parameter(Position = 2, ParameterSetName = 'TriangleOpacityHSL', Mandatory = $True)]
                    [int]$Side3,
                    
                    [Parameter(ParameterSetName = 'CircleTransparencyRGB',   Mandatory = $True)]
                    [Parameter(ParameterSetName = 'SquareTransparencyRGB',   Mandatory = $True)]
                    [Parameter(ParameterSetName = 'TriangleTransparencyRGB', Mandatory = $True)]
                    [Parameter(ParameterSetName = 'CircleTransparencyHSL',   Mandatory = $True)]
                    [Parameter(ParameterSetName = 'SquareTransparencyHSL',   Mandatory = $True)]
                    [Parameter(ParameterSetName = 'TriangleTransparencyHSL', Mandatory = $True)]
                    [int]$Transparency,

                    [Parameter(ParameterSetName = 'CircleOpacityRGB',   Mandatory = $True)]
                    [Parameter(ParameterSetName = 'SquareOpacityRGB',   Mandatory = $True)]
                    [Parameter(ParameterSetName = 'TriangleOpacityRGB', Mandatory = $True)]
                    [Parameter(ParameterSetName = 'CircleOpacityHSL',   Mandatory = $True)]
                    [Parameter(ParameterSetName = 'SquareOpacityHSL',   Mandatory = $True)]
                    [Parameter(ParameterSetName = 'TriangleOpacityHSL', Mandatory = $True)]
                    [int]$Opacity,

                    [Parameter(ParameterSetName = 'CircleTransparencyRGB')]
                    [Parameter(ParameterSetName = 'SquareTransparencyRGB')]
                    [Parameter(ParameterSetName = 'TriangleTransparencyRGB')]
                    [Parameter(ParameterSetName = 'CircleOpacityRGB')]
                    [Parameter(ParameterSetName = 'SquareOpacityRGB')]
                    [Parameter(ParameterSetName = 'TriangleOpacityRGB')]
                    [int]$Red,

                    [Parameter(ParameterSetName = 'CircleTransparencyRGB')]
                    [Parameter(ParameterSetName = 'SquareTransparencyRGB')]
                    [Parameter(ParameterSetName = 'TriangleTransparencyRGB')]
                    [Parameter(ParameterSetName = 'CircleOpacityRGB')]
                    [Parameter(ParameterSetName = 'SquareOpacityRGB')]
                    [Parameter(ParameterSetName = 'TriangleOpacityRGB')]
                    [int]$Green,

                    [Parameter(ParameterSetName = 'CircleTransparencyRGB')]
                    [Parameter(ParameterSetName = 'SquareTransparencyRGB')]
                    [Parameter(ParameterSetName = 'TriangleTransparencyRGB')]
                    [Parameter(ParameterSetName = 'CircleOpacityRGB')]
                    [Parameter(ParameterSetName = 'SquareOpacityRGB')]
                    [Parameter(ParameterSetName = 'TriangleOpacityRGB')]
                    [int]$Blue,

                    [Parameter(ParameterSetName = 'CircleTransparencyHSL')]
                    [Parameter(ParameterSetName = 'SquareTransparencyHSL')]
                    [Parameter(ParameterSetName = 'TriangleTransparencyHSL')]
                    [Parameter(ParameterSetName = 'CircleOpacityHSL')]
                    [Parameter(ParameterSetName = 'SquareOpacityHSL')]
                    [Parameter(ParameterSetName = 'TriangleOpacityHSL')]
                    [int]$Hue,

                    [Parameter(ParameterSetName = 'CircleTransparencyHSL')]
                    [Parameter(ParameterSetName = 'SquareTransparencyHSL')]
                    [Parameter(ParameterSetName = 'TriangleTransparencyHSL')]
                    [Parameter(ParameterSetName = 'CircleOpacityHSL')]
                    [Parameter(ParameterSetName = 'SquareOpacityHSL')]
                    [Parameter(ParameterSetName = 'TriangleOpacityHSL')]
                    [int]$Sat,

                    [Parameter(ParameterSetName = 'CircleTransparencyHSL')]
                    [Parameter(ParameterSetName = 'SquareTransparencyHSL')]
                    [Parameter(ParameterSetName = 'TriangleTransparencyHSL')]
                    [Parameter(ParameterSetName = 'CircleOpacityHSL')]
                    [Parameter(ParameterSetName = 'SquareOpacityHSL')]
                    [Parameter(ParameterSetName = 'TriangleOpacityHSL')]
                    [int]$Lum
                )
            }
            
            function FMO {
                [CmdletBinding()] param()
                DynamicParam {
                    $Color = New-ParamSet @(
                        New-ParamSet @(
                            New-Param ([int]) Red
                            New-Param ([int]) Green
                            New-Param ([int]) Blue
                        )
                        New-ParamSet @(
                            New-Param ([int]) Hue
                            New-Param ([int]) Sat
                            New-Param ([int]) Lum
                        )
                    )
                    $Tint = New-ParamSet @(
                        New-ParamSet @(
                            New-Param ([int]) Transparency -Mandatory
                            $Color
                        )
                        New-ParamSet @(
                            New-Param ([int]) Opacity -Mandatory
                            $Color
                        )
                    )
                    New-ParamSet @(
                        New-ParamSet @(
                            New-Param 0 ([int]) Radius -Mandatory
                            $Tint
                        )
                        New-ParamSet @(
                            New-Param 0 ([int]) Width  -Mandatory
                            New-Param 1 ([int]) Height -Mandatory
                            $Tint
                        )
                        New-ParamSet @(
                            New-Param 0 ([int]) Side1 -Mandatory
                            New-Param 1 ([int]) Side2 -Mandatory
                            New-Param 2 ([int]) Side3 -Mandatory
                            $Tint
                        )
                    )
                }
            }

            Compare-Parameters FMO CMO | Should -BeNull

            function FMO {
                [CmdletBinding()] param()
                DynamicParam {
                    $Color = @(
                        New-ParamSet @(
                            New-Param ([int]) Red
                            New-Param ([int]) Green
                            New-Param ([int]) Blue
                        )
                        New-ParamSet @(
                            New-Param ([int]) Hue
                            New-Param ([int]) Sat
                            New-Param ([int]) Lum
                        )
                    )
                    $Tint = @(
                        New-ParamSet @(
                            New-Param ([int]) Transparency -Mandatory
                            $Color
                        )
                        New-ParamSet @(
                            New-Param ([int]) Opacity -Mandatory
                            $Color
                        )
                    )
                    New-ParamSet @(
                        New-ParamSet @(
                            New-Param 0 ([int]) Radius -Mandatory
                            $Tint
                        )
                        New-ParamSet @(
                            New-Param 0 ([int]) Width  -Mandatory
                            New-Param 1 ([int]) Height -Mandatory
                            $Tint
                        )
                        New-ParamSet @(
                            New-Param 0 ([int]) Side1 -Mandatory
                            New-Param 1 ([int]) Side2 -Mandatory
                            New-Param 2 ([int]) Side3 -Mandatory
                            $Tint
                        )
                    )
                }
            }

            Compare-Parameters FMO CMO | Should -BeNull

            function FMO { # Named parameter sets
                [CmdletBinding()] param()
                DynamicParam {
                    $Color = @(
                        New-ParamSet RGB @(
                            New-Param ([int]) Red
                            New-Param ([int]) Green
                            New-Param ([int]) Blue
                        )
                        New-ParamSet HSL @(
                            New-Param ([int]) Hue
                            New-Param ([int]) Sat
                            New-Param ([int]) Lum
                        )
                    )
                    $Tint = @(
                        New-ParamSet Transparency @(
                            New-Param ([int]) Transparency -Mandatory
                            $Color
                        )
                        New-ParamSet Opacity @(
                            New-Param ([int]) Opacity -Mandatory
                            $Color
                        )
                    )
                    New-ParamSet Root @(
                        New-ParamSet Circle @(
                            New-Param 0 ([int]) Radius -Mandatory
                            $Tint
                        )
                        New-ParamSet Square @(
                            New-Param 0 ([int]) Width  -Mandatory
                            New-Param 1 ([int]) Height -Mandatory
                            $Tint
                        )
                        New-ParamSet Triangle @(
                            New-Param 0 ([int]) Side1 -Mandatory
                            New-Param 1 ([int]) Side2 -Mandatory
                            New-Param 2 ([int]) Side3 -Mandatory
                            $Tint
                        )
                    )
                }
            }

            Compare-Parameters FMO CMO | Should -BeNull
        }
    
    }
    Context 'Simulations' {
    
        it 'Where-Object' {
            function WhereObject {
                [CmdletBinding()] param()
                DynamicParam {
                    $MandatoryOperators = @(
                        'CEQ', 'NE', 'CNE', 'GT', 'CGT', 'LT', 'CLT', 'GE', 'CGE', 'LE', 'CLE',
                        'Like', 'CLike', 'NotLike', 'CNotLike', 'Match', 'CMatch', 'NotMatch', 'CNotMatch',
                        'Contains', 'CContains', 'NotContains', 'CNotContains',
                        'In', 'CIn', 'NotIn', 'CNotIn', 'Is', 'IsNot'
                    )
                    New-ParamSet @(
                        New-ParamSet @(
                            New-ParamSet @(
                                New-Param 0 ([scriptblock]) FilterScript -Mandatory
                                New-Param ([psobject]) InputObject
                            )
                        )
                        New-ParamSet @(
                            New-Param 0 ([string]) Property -Mandatory
                            New-ParamSet @(
                                New-Param 1 ([object]) Value
                                New-Param ([switch]) EQ
                                New-Param ([psobject]) InputObject
                            )
                            foreach ($Operator in $MandatoryOperators) {
                                New-ParamSet @(
                                    New-Param 1 ([object]) Value
                                    New-Param ([switch]) $Operator -Mandatory
                                    New-Param ([psobject]) InputObject
                                )
                            }
                        )
                        New-ParamSet @(
                            New-Param 0 ([string]) Property -Mandatory
                            New-ParamSet @(
                                New-Param ([switch]) Not -Mandatory
                                New-Param ([psobject]) InputObject
                            )
                        )
                    )
                }
            }
            
            Compare-Parameters WhereObject Where-Object | Should -BeNull

        }
    }

}
