# Version 0.2.2

using namespace System.Management
using namespace System.Management.Automation
Add-Type -AssemblyName System.Management.Automation

function New-Parameter {
    [CmdletBinding()][OutputType([System.Management.Automation.RuntimeDefinedParameterDictionary])] param(
        [Parameter(Position = 0, Mandatory = $True, ParameterSetName = 'PositionName')]
        [Parameter(Position = 0, Mandatory = $True, ParameterSetName = 'PositionNameDefault')]
        [Parameter(Position = 0, Mandatory = $True, ParameterSetName = 'PositionTypeName')]
        [Parameter(Position = 0, Mandatory = $True, ParameterSetName = 'PositionTypeNameDefault')]
        [int]$Position,

        [Parameter(Position = 0, Mandatory = $True, ParameterSetName = 'TypeName')]
        [Parameter(Position = 0, Mandatory = $True, ParameterSetName = 'TypeNameDefault')]
        [Parameter(Position = 1, Mandatory = $True, ParameterSetName = 'PositionTypeName')]
        [Parameter(Position = 1, Mandatory = $True, ParameterSetName = 'PositionTypeNameDefault')]
        [type]$Type = [type]'Object',
        
        [Parameter(Position = 0, Mandatory = $True, ParameterSetName = 'Name')]
        [Parameter(Position = 1, Mandatory = $True, ParameterSetName = 'NameDefault')]
        [Parameter(Position = 1, Mandatory = $True, ParameterSetName = 'TypeName')]
        [Parameter(Position = 2, Mandatory = $True, ParameterSetName = 'TypeNameDefault')]
        [Parameter(Position = 1, Mandatory = $True, ParameterSetName = 'PositionName')]
        [Parameter(Position = 2, Mandatory = $True, ParameterSetName = 'PositionNameDefault')]
        [Parameter(Position = 2, Mandatory = $True, ParameterSetName = 'PositionTypeName')]
        [Parameter(Position = 3, Mandatory = $True, ParameterSetName = 'PositionTypeNameDefault')]
        [string]$Name,
        
        [Parameter(Position = 2, Mandatory = $True, ParameterSetName = 'NameDefault')]
        [Parameter(Position = 3, Mandatory = $True, ParameterSetName = 'TypeNameDefault')]
        [Parameter(Position = 3, Mandatory = $True, ParameterSetName = 'PositionNameDefault')]
        [Parameter(Position = 4, Mandatory = $True, ParameterSetName = 'PositionTypeNameDefault')]
        [object]$Default,
        
        [Parameter(ParameterSetName = 'Name')]
        [Parameter(ParameterSetName = 'NameDefault')]
        [Parameter(ParameterSetName = 'TypeName')]
        [Parameter(ParameterSetName = 'TypeNameDefault')]
        [Parameter(ParameterSetName = 'PositionName')]
        [Parameter(ParameterSetName = 'PositionNameDefault')]
        [Parameter(ParameterSetName = 'PositionTypeName')]
        [Parameter(ParameterSetName = 'PositionTypeNameDefault')]
        [switch]$Mandatory,
        
        [Parameter(ParameterSetName = 'Name')]
        [Parameter(ParameterSetName = 'NameDefault')]
        [Parameter(ParameterSetName = 'TypeName')]
        [Parameter(ParameterSetName = 'TypeNameDefault')]
        [Parameter(ParameterSetName = 'PositionName')]
        [Parameter(ParameterSetName = 'PositionNameDefault')]
        [Parameter(ParameterSetName = 'PositionTypeName')]
        [Parameter(ParameterSetName = 'PositionTypeNameDefault')]
        [switch]$ValueFromPipeline,
        
        [Parameter(ParameterSetName = 'Name')]
        [Parameter(ParameterSetName = 'NameDefault')]
        [Parameter(ParameterSetName = 'TypeName')]
        [Parameter(ParameterSetName = 'TypeNameDefault')]
        [Parameter(ParameterSetName = 'PositionName')]
        [Parameter(ParameterSetName = 'PositionNameDefault')]
        [Parameter(ParameterSetName = 'PositionTypeName')]
        [Parameter(ParameterSetName = 'PositionTypeNameDefault')]
        [switch]$ValueFromPipelineByPropertyName,
        
        [Parameter(ParameterSetName = 'Name')]
        [Parameter(ParameterSetName = 'NameDefault')]
        [Parameter(ParameterSetName = 'TypeName')]
        [Parameter(ParameterSetName = 'TypeNameDefault')]
        [Parameter(ParameterSetName = 'PositionName')]
        [Parameter(ParameterSetName = 'PositionNameDefault')]
        [Parameter(ParameterSetName = 'PositionTypeName')]
        [Parameter(ParameterSetName = 'PositionTypeNameDefault')]
        [switch]$ValueFromRemainingArguments,
        
        [Parameter(ParameterSetName = 'Name')]
        [Parameter(ParameterSetName = 'NameDefault')]
        [Parameter(ParameterSetName = 'TypeName')]
        [Parameter(ParameterSetName = 'TypeNameDefault')]
        [Parameter(ParameterSetName = 'PositionName')]
        [Parameter(ParameterSetName = 'PositionNameDefault')]
        [Parameter(ParameterSetName = 'PositionTypeName')]
        [Parameter(ParameterSetName = 'PositionTypeNameDefault')]
        [string]$HelpMessage,
        
        [Parameter(ParameterSetName = 'Name')]
        [Parameter(ParameterSetName = 'NameDefault')]
        [Parameter(ParameterSetName = 'TypeName')]
        [Parameter(ParameterSetName = 'TypeNameDefault')]
        [Parameter(ParameterSetName = 'PositionName')]
        [Parameter(ParameterSetName = 'PositionNameDefault')]
        [Parameter(ParameterSetName = 'PositionTypeName')]
        [Parameter(ParameterSetName = 'PositionTypeNameDefault')]
        [string]$HelpMessageBaseName,
        
        [Parameter(ParameterSetName = 'Name')]
        [Parameter(ParameterSetName = 'NameDefault')]
        [Parameter(ParameterSetName = 'TypeName')]
        [Parameter(ParameterSetName = 'TypeNameDefault')]
        [Parameter(ParameterSetName = 'PositionName')]
        [Parameter(ParameterSetName = 'PositionNameDefault')]
        [Parameter(ParameterSetName = 'PositionTypeName')]
        [Parameter(ParameterSetName = 'PositionTypeNameDefault')]
        [string]$HelpMessageResourceId,
        
        [Parameter(ParameterSetName = 'Name')]
        [Parameter(ParameterSetName = 'NameDefault')]
        [Parameter(ParameterSetName = 'TypeName')]
        [Parameter(ParameterSetName = 'TypeNameDefault')]
        [Parameter(ParameterSetName = 'PositionName')]
        [Parameter(ParameterSetName = 'PositionNameDefault')]
        [Parameter(ParameterSetName = 'PositionTypeName')]
        [Parameter(ParameterSetName = 'PositionTypeNameDefault')]
        [switch]$DontShow
    )
    Process {
        $Attribute = New-Object ParameterAttribute
        foreach (
            $PropertyName in (
                'Mandatory',
                'Position',
                'ParameterSetName',
                'ValueFromPipeline',
                'ValueFromPipelineByPropertyName',
                'ValueFromRemainingArguments',
                'HelpMessage',
                'HelpMessageBaseName',
                'HelpMessageResourceId',
                'DontShow'
            )
        ) { 
            if ($PSBoundParameters.ContainsKey($PropertyName)) {
                $Attribute.$PropertyName = $PSBoundParameters[$PropertyName]
            }
        }
        $Collection = [System.Collections.ObjectModel.Collection[System.Attribute]]::new()
        $Collection.Add($Attribute)
        $Parameter = [RuntimeDefinedParameter]::new($Name, $Type, $Collection)
        if ($PSBoundParameters.ContainsKey('Default')) { $Parameter.Value = $Default }
        $Dictionary = [RuntimeDefinedParameterDictionary]::new()
        $Dictionary.Add($Parameter.Name, $Parameter)
        $Dictionary
    }
}; Set-Alias New-Param New-Parameter; Set-Alias NPM New-Parameter

function New-ParameterSet {
    [CmdletBinding(DefaultParameterSetName = 'Anonymous')][OutputType([System.Management.Automation.RuntimeDefinedParameterDictionary])] param(
        [Parameter(Position = 0, ParameterSetName = 'Anonymous', Mandatory = $True, ValueFromPipeLine = $True)]
        [Parameter(Position = 1, ParameterSetName = 'Name',      Mandatory = $True, ValueFromPipeLine = $True)]
        [RuntimeDefinedParameterDictionary[]]$ParameterSets,

        [Parameter(Position = 0, ParameterSetName = 'Name', Mandatory = $True)]
        [Alias("Name")][String]$SetName
    )
    Begin {
        function CopyAttribute {
            [CmdletBinding()] param(
                [Parameter(Mandatory = $True)][RuntimeDefinedParameter]$ToParameter,
                [HashTable]$Properties = @{},
                [Parameter(Mandatory = $True, ValueFromPipeLine = $True)][ParameterAttribute]$Attribute,
                [String[]]$ExcludeTemplateProperty = ('ExperimentName', 'ExperimentAction', 'TypeId')
            )
            Process {
                $NewAttribute = [ParameterAttribute]::new() 
                if ($Attribute) {
                    foreach ($Property in $Attribute.PSObject.Properties) {
                        if ($Null -ne $Property.Value -and $ExcludeTemplateProperty -NotContains $Property.Name) {
                            $NewAttribute.($Property.Name) = $Property.Value
                        }
                    }
                }
                foreach ($Property in $Properties.GetEnumerator()) {
                    $NewAttribute.($Property.Name) = $Property.Value
                }
                $ToParameter.Attributes.Add($NewAttribute)
            }
        }
        function AddParameter {
            [CmdletBinding(DefaultParameterSetName = 'Name')] param( 
                [Parameter(Mandatory = $True)][RuntimeDefinedParameterDictionary]$Dictionary,
                [Parameter(Mandatory = $True)][type]$Type,
                [Parameter(Mandatory = $True)][string]$Name,
                [Switch]$Force
            )
            Process {
                if ($Force -and $Dictionary.ContainsKey($Name)) {
                    $Dictionary[$Name]
                }
                else {
                    $Collection = [System.Collections.ObjectModel.Collection[System.Attribute]]::new()
                    $Parameter = [RuntimeDefinedParameter]::new($Name, $Type, $Collection)
                    $Dictionary.Add($Parameter.Name, $Parameter)
                    $Parameter
                }
            }
        }
        function CopyParameter {
            [CmdletBinding()] param(
                [Parameter(Mandatory = $True)][RuntimeDefinedParameterDictionary]$ToDirectory,
                [HashTable]$Properties = @{},
                [Parameter(Mandatory = $True, ValueFromPipeLine = $True)][RuntimeDefinedParameter]$Parameter,
                [Switch]$Force
            )
            Process {
                $NewParameter = AddParameter $ToDirectory $Parameter.ParameterType $Parameter.Name -Force:$Force
                $NewParameter.Value = $Parameter.Value
                $Parameter.Attributes | CopyAttribute $NewParameter $Properties
            }
        }
    }
    Process {
        $Mandatory = [System.Collections.ObjectModel.Collection[RuntimeDefinedParameter]]::new()
        $Optional = [System.Collections.ObjectModel.Collection[RuntimeDefinedParameter]]::new()
        $SubSets = [System.Collections.ObjectModel.Collection[RuntimeDefinedParameterDictionary]]::new()
        foreach ($ParameterSet in $ParameterSets) {
            $SubSet = $Null
            foreach ($Parameter in $ParameterSet.Values) {
                foreach ($Attribute in $Parameter.Attributes) {
                    $Name = $Attribute.ParameterSetName
                    if ($Name -eq '__AllParameterSets') {
                        if ($Attribute.Mandatory) { $Mandatory.Add($Parameter) }
                        else { $Optional.Add($Parameter) }
                    }
                    else { $SubSet = $ParameterSet }
                }
            }
            if ($SubSet) { $SubSets.Add($SubSet) }
        }
        $0 = if ($SetName) { $SetName } else { '0' }
        $Dictionary = [RuntimeDefinedParameterDictionary]::new()
        if (@($SubSets)) {
            $SetNames = [System.Collections.Generic.HashSet[string]]::New()
            $Index = 1
            foreach ($SubSet in $SubSets) {
                $Name, $Path0 = $Null
                foreach ($Parameter in $SubSet.Values) {
                    $NewParameter = AddParameter -Force $Dictionary $Parameter.ParameterType $Parameter.Name
                    foreach ($Attribute in $Parameter.Attributes) {
                        $Path = $Attribute.ParameterSetName.Split('.', 2)
                        if ($Path0) {
                            if ($Path0 -ne $Path[0]) {
                                Throw [InvalidOperationException]"$($Attribute.ParameterSetName) is not part of the $Path0 set"
                            }
                        }
                        else {
                            $Path0 = $Path[0]
                            $Name = if ($Path0 -eq '0') { $Index.ToString() } else { $Path0 }
                        }
                        $ParameterSetName = if ($Path.Count -gt 1) { $0 + '.' + $Name + '.' + $Path[1] } else { $0 + '.' + $Name }
                        $Attribute | CopyAttribute $NewParameter @{ ParameterSetName = $ParameterSetName }
                        $Null = $SetNames.Add( $ParameterSetName )
                    }
                }
                $Index++
            }
            if (@($Mandatory) -or @($Optional)) {
                foreach ($ParameterSetName in $SetNames) {
                    $Mandatory + $Optional | CopyParameter -Force $Dictionary @{ ParameterSetName = $ParameterSetName }
                }
            }
        }
        elseif (@($Mandatory)) {
            $Mandatory | CopyParameter $Dictionary @{ ParameterSetName = $0 }
        }
        $Optional | CopyParameter -Force $Dictionary @{ ParameterSetName = $0 }
        $Dictionary
    }
}; Set-Alias New-ParamSet New-ParameterSet; Set-Alias NPS New-ParameterSet

Export-ModuleMember -Function * -Alias *
