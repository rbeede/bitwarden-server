﻿using Bit.Core.Entities;

namespace Bit.Core.OrganizationFeatures.Groups;

public interface IDeleteGroupCommand
{
    Task DeleteAsync(Group group);

    Task DeleteManyAsync(IEnumerable<Group> groups);
}