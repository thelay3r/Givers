export type JumpModifier = {
    Name: string,
    Delta: number,
    RawPercent: number,
    UseBaseJump: boolean,
    PreviousJump: number,
    Type: 'Buff' | 'Debuff',
    Priority: number,
    AppliedAt: number,
}


export type JumpComponentData = {
    DefaultJump: number,
    CurrentJump: number,
    LastJump: number,
    Cache: {[string]: JumpModifier},
    PendingValidation: {[string]: JumpModifier},
}


export type JumpInfo = {
    Current: number,
    Default: number,
    Last: number,
    Max: number,
    Min: number,
    ModifierCount: number,
    IsUsingJumpHeight: boolean,
}


export type AmplifyConfig = {
    Name: string,
    Percent: number,
    UseBaseJump: boolean,
    Priority: number,
    ClearBuffsOnDebuff: boolean,
    Replicated: boolean,
}


export type RevertConfig = {
    Name: string,
    Replicated: boolean,
}


export type IJumpPowerComponent = {
    -- Данные
    Entity: any,
    Character: any,
    Humanoid: any,
    Data: JumpComponentData,


    -- Приватные методы
    _SetJumpPower: (self: IJumpPowerComponent, JumpValue: number) -> boolean,
    _ReportJumpToServer: (self: IJumpPowerComponent, JumpValue: number) -> (),
    _ClearAllModifiers: (self: IJumpPowerComponent) -> (),


    -- Публичные методы
    Amplify: (self: IJumpPowerComponent, Data: AmplifyConfig) -> boolean,
    Revert: (self: IJumpPowerComponent, Data: RevertConfig) -> boolean,
    GetModifier: (self: IJumpPowerComponent, Name: string) -> JumpModifier,
    GetAllModifiers: (self: IJumpPowerComponent) -> {[string]: JumpModifier},
    GetJumpInfo: (self: IJumpPowerComponent) -> JumpInfo,
    ResetToDefault: (self: IJumpPowerComponent) -> (),
    SetConfig: (self: IJumpPowerComponent, NewConfig: {[string]: any}) -> (),
}


export type IJumpPowerController = {
    new: (Entity: any) -> IJumpPowerComponent,
    SetMaxJump: (maxJump: number) -> (),
    SetMinJump: (minJump: number) -> (),
    SetUseJumpHeight: (useHeight: boolean) -> (),
    SetDebug: (enabled: boolean) -> (),
}


export type JumpInfoReturn = {
    Current: number,
    Default: number,
    Last: number,
    Max: number,
    Min: number,
    ModifierCount: number,
    IsUsingJumpHeight: boolean,
}


return {
    JumpModifier = {} :: JumpModifier,
    JumpComponentData = {} :: JumpComponentData,
    JumpInfo = {} :: JumpInfo,
    AmplifyConfig = {} :: AmplifyConfig,
    RevertConfig = {} :: RevertConfig,
    IJumpPowerComponent = {} :: IJumpPowerComponent,
    IJumpPowerController = {} :: IJumpPowerController,
    JumpInfoReturn = {} :: JumpInfoReturn,
}