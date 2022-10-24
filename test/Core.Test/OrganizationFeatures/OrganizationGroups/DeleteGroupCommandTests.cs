﻿using Bit.Core.Entities;
using Bit.Core.Enums;
using Bit.Core.OrganizationFeatures.OrganizationGroups;
using Bit.Core.Repositories;
using Bit.Core.Services;
using Bit.Core.Test.AutoFixture.OrganizationFixtures;
using Bit.Test.Common.AutoFixture;
using Bit.Test.Common.AutoFixture.Attributes;
using NSubstitute;
using Xunit;

namespace Bit.Core.Test.OrganizationFeatures.OrganizationGroups;

[SutProviderCustomize]
public class DeleteGroupCommandTests
{
    [Theory, BitAutoData]
    public async Task DeleteAsync_DeletesGroup(Group group, SutProvider<DeleteGroupCommand> sutProvider)
    {
        // Act
        await sutProvider.Sut.DeleteAsync(group);

        // Assert
        await sutProvider.GetDependency<IGroupRepository>().Received().DeleteAsync(group);
        await sutProvider.GetDependency<IEventService>().Received().LogGroupEventAsync(group, EventType.Group_Deleted);
    }

    [Theory, BitAutoData]
    [OrganizationCustomize]
    public async Task DeleteManyAsync_DeletesManyGroup(Organization org, Group group, Group group2, SutProvider<DeleteGroupCommand> sutProvider)
    {
        // Arrange
        var groupIds = new[] { group.Id, group2.Id };
        var groups = new[] { group, group2 };

        sutProvider.GetDependency<IGroupRepository>()
            .GetManyByManyIds(groupIds)
            .Returns(groups);

        // Act
        await sutProvider.Sut.DeleteManyAsync(groups);

        // Assert
        await sutProvider.GetDependency<IGroupRepository>().Received()
            .DeleteManyAsync(Arg.Is<IEnumerable<Guid>>(ids => ids.SequenceEqual(groups.Select(g => g.Id))));

        await sutProvider.GetDependency<IEventService>().Received().LogGroupEventAsync(group, EventType.Group_Deleted, Arg.Any<DateTime>());
        await sutProvider.GetDependency<IEventService>().Received().LogGroupEventAsync(group2, EventType.Group_Deleted, Arg.Any<DateTime>());
    }
}